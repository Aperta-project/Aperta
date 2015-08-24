##
# This class represents the paper in the system.
class Paper < ActiveRecord::Base
  include EventStream::Notifiable
  include AASM

  belongs_to :creator, inverse_of: :submitted_papers, class_name: 'User', foreign_key: :user_id
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :locked_by, class_name: 'User'
  belongs_to :striking_image, class_name: 'Figure'

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :versioned_texts, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :bibitems, dependent: :destroy
  has_many :supporting_information_files, dependent: :destroy
  has_many :paper_roles, inverse_of: :paper, dependent: :destroy
  has_many :assigned_users, -> { uniq }, through: :paper_roles, source: :user
  has_many :phases, -> { order 'phases.position ASC' }, dependent: :destroy, inverse_of: :paper
  has_many :tasks, through: :phases
  has_many :comments, through: :tasks
  has_many :comment_looks, through: :comments
  has_many :participants, through: :tasks
  has_many :journal_roles, through: :journal
  has_many :authors, -> { order 'authors.position ASC' }
  has_many :activities
  has_many :decisions, -> { order 'revision_number DESC' }, dependent: :destroy
  has_many :discussion_topics, inverse_of: :paper, dependent: :destroy

  validates :paper_type, presence: true
  validates :short_title, presence: true, uniqueness: true
  validates :journal, presence: true

  validates :short_title, :title, length: { maximum: 255 }

  delegate :admins, :editors, :reviewers, to: :journal, prefix: :possible

  aasm column: :publishing_state do
    state :unsubmitted, initial: true # currently being authored
    state :submitted
    state :checking # small change that does not require resubmission, as in a tech check
    state :in_revision # has revised decision and requires resubmission
    state :accepted
    state :rejected
    state :published

    event(:submit) do
      transitions from: [:unsubmitted, :in_revision],
                  to: :submitted,
                  guards: :metadata_tasks_completed?,
                  after: [:prevent_edits!,
                          :major_version!,
                          :set_submitted_at!,
                          :find_or_create_paper_in_salesforce,
                          :create_billing_and_pfa_case]
    end

    event(:minor_check) do
      transitions from: :submitted,
                  to: :checking,
                  after: :allow_edits!
    end

    event(:submit_minor_check) do
      transitions from: :checking,
                  to: :submitted,
                  after: :prevent_edits!
    end

    event(:minor_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: :allow_edits!
    end

    event(:major_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: :allow_edits!
    end

    event(:accept) do
      transitions from: :submitted,
                  to: :accepted
    end

    event(:reject) do
      transitions from: :submitted,
                  to: :rejected
    end

    event(:publish) do
      transitions from: :submitted,
                  to: :published,
                  after: :set_published_at!
    end
  end

  def make_decision(decision)
    public_send "#{decision.verdict}!"
  end

  def body
    latest_version.text
  end

  def body=(new_body)
    latest_version.update(text: new_body)
  end

  def version_string
    latest_version.version_string
  end

  # Public: Find `PaperRole`s for the given role and user.
  #
  # role  - The role to search for.
  # user  - The user to search `PaperRole` against.
  #
  # Examples
  #
  #   Paper.role_for(role: 'editor', user: User.first)
  #   # => [<#123: PaperRole>, <#124: PaperRole>]
  #
  # Returns an ActiveRelation with <tt>PaperRole</tt>s.
  def role_for(role:, user:)
    paper_roles.where(role: role, user_id: user.id)
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  # Public: Returns the paper title if it's present, otherwise short title is shown.
  #
  # Examples
  #
  #   display_title
  #   # => "Studies on the effect of humans living with other humans"
  #   # or
  #   # => "some-short-title"
  #
  # Returns a String.
  def display_title
    title.present? ? title : short_title
  end

  # Public: Returns one of the admins from the paper.
  #
  # Examples
  #
  #   admin
  #   # => <#124: User>
  #
  # Returns a User object.
  def admin
    admins.first
  end

  # Public: Returns one of the editors from the paper.
  #
  # Examples
  #
  #   editor
  #   # => <#124: User>
  #
  # Returns a User object.
  def editor
    editors.first
  end

  def locked? # :nodoc:
    locked_by_id.present?
  end

  def unlocked? # :nodoc:
    !locked?
  end

  def locked_by?(user) # :nodoc:
    locked_by_id == user.id
  end

  def lock_by(user) # :nodoc:
    update_attribute(:locked_by, user)
  end

  def unlock # :nodoc:
    update_attribute(:locked_by, nil)
  end

  def heartbeat # :nodoc:
    update_attribute(:last_heartbeat_at, Time.now)
  end

  # Accepts any args the state transition accepts
  def metadata_tasks_completed?(*)
    tasks.metadata.count == tasks.metadata.completed.count
  end

  # Accepts any args the state transition accepts
  def prevent_edits!(*)
    update!(editable: false)
  end

  def allow_edits!
    update!(editable: true)
  end

  %w(admins editors reviewers collaborators).each do |relation|
    ###
    # :method: <roles>
    # Public: Return user records by role in the paper.
    #
    # Examples
    #
    #   editors   # => [user1, user2]
    #
    # Returns an Array of User records.
    #
    # Signature
    #
    #   #<roles>
    #
    # role - A role name on the paper
    define_method relation.to_sym do
      assigned_users.merge(PaperRole.send(relation))
    end

    ###
    # :method: <role>?
    # Public: Checks whether the given user belongs to the role.
    #
    # user - The user record
    #
    # Examples
    #
    #   editor?(user)        # => true
    #   collaborator?(user)  # => false
    #
    # Returns true if the user has the role on the paper, false otherwise.
    #
    # Signature
    #
    #   #<role>?(arg)
    #
    # role - A role name on the paper
    #
    define_method("#{relation.singularize}?".to_sym) do |user|
      return false unless user.present?
      send(relation).exists?(user.id)
    end
  end

  # overload this method for use in emails
  def abstract
    super.present? ? super : default_abstract
  end

  def authors_list
    authors.map.with_index { |author, index|
      "#{index + 1}. #{author.last_name}, #{author.first_name} from #{author.specific.affiliation}"
    }.join("\n")
  end

  private

  def latest_version
    versioned_texts.active.first_or_initialize
  end

  def major_version!(submitting_user)
    latest_version.major_version!(submitting_user)
  end

  def default_abstract
    Nokogiri::HTML(body).text.truncate_words 100
  end

  def set_published_at!
    update!(published_at: Time.current.utc)
  end

  def set_submitted_at!
    update!(submitted_at: Time.current.utc)
  end

  def create_paper_in_salesforce!(*)
    SalesforceServices::API.delay.create_manuscript(paper_id: self.id)
  end

  def update_paper_in_salesforce!(*)
    SalesforceServices::API.delay.update_manuscript(paper_id: self.id)
  end

  def find_or_create_paper_in_salesforce(*)
    SalesforceServices::API.delay.find_or_create_manuscript(paper_id: self.id)
  end

  def create_billing_and_pfa_case(*)
    SalesforceServices::API.delay.create_billing_and_pfa_case(paper_id: self.id)
  end
end
