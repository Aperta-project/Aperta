##
# This class represents the paper in the system.
class Paper < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :creator, inverse_of: :submitted_papers, class_name: 'User', foreign_key: :user_id
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :locked_by, class_name: 'User'
  belongs_to :striking_image, class_name: 'Figure'

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :supporting_information_files, class_name: 'TahiSupportingInformation::File', dependent: :destroy
  has_many :paper_roles, inverse_of: :paper, dependent: :destroy
  has_many :assigned_users, -> { uniq }, through: :paper_roles, source: :user
  has_many :phases, -> { order 'phases.position ASC' }, dependent: :destroy, inverse_of: :paper
  has_many :tasks, through: :phases
  has_many :participants, through: :tasks
  has_many :journal_roles, through: :journal
  has_many :authors, -> { order 'authors.position ASC' }
  has_many :activity_feeds
  has_many :decisions, -> { order 'revision_number DESC' }

  validates :paper_type, presence: true
  validates :short_title, presence: true, uniqueness: true
  validates :journal, presence: true
  validate :metadata_tasks_completed?, if: :submitting?

  delegate :admins, :editors, :reviewers, to: :journal, prefix: :possible

  class << self
    # Public: Find papers in the 'submitted' state only.
    #
    # Examples
    #
    #   Paper.submitted
    #   # => [<#123: Paper>, <#124: Paper>]
    #
    # Returns an ActiveRelation.
    def submitted
      where(submitted: true)
    end

    # Public: Find papers that are not in 'submitted' state.
    #
    # Examples
    #
    #   Paper.ongoing
    #   # => [<#123: Paper>, <#124: Paper>]
    #
    # Returns an ActiveRelation.
    def ongoing
      where(submitted: false)
    end

    # Public: Find papers that have been published.
    #
    # Examples
    #
    #   Paper.published
    #   # => [<#123: Paper>, <#124: Paper>]
    #
    # Returns an ActiveRelation.
    def published
      where.not(published_at: nil)
    end

    # Public: Find papers that haven't been published yet.
    #
    # Examples
    #
    #   Paper.unpublished
    #   # => [<#123: Paper>, <#124: Paper>]
    #
    # Returns an ActiveRelation.
    def unpublished
      where(published_at: nil)
    end
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

  def latest_decision
    decisions.order("created_at DESC").limit(1).first
  end

  def previous_decisions
    decisions.order("created_at DESC").offset(1)
  end

  def create_decision!
    decisions.create!
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

  def submitting? # :nodoc:
    submitted_changed? && submitted
  end

  def unlock # :nodoc:
    update_attribute(:locked_by, nil)
  end

  def heartbeat # :nodoc:
    update_attribute(:last_heartbeat_at, Time.now)
  end

  def metadata_tasks_completed? # :nodoc:
    return unless uncompleted_tasks?
    errors.add(:base, "can't submit a paper when all of the metadata tasks aren't completed")
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
    # Returns an Array of User records.
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

  private

  def uncompleted_tasks?
    tasks.metadata.count != tasks.metadata.completed.count
  end
end
