##
# This class represents the paper in the system.
class Paper < ActiveRecord::Base
  include EventStream::Notifiable
  include PaperTaskFinders
  include AASM
  include ActionView::Helpers::SanitizeHelper

  belongs_to :creator, inverse_of: :submitted_papers, class_name: 'User', foreign_key: :user_id
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :striking_image, class_name: 'Figure'

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :versioned_texts, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :bibitems, dependent: :destroy
  has_many :supporting_information_files, dependent: :destroy
  has_many :paper_roles, dependent: :destroy
  has_many :users, -> { uniq }, through: :paper_roles
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

  serialize :withdrawals, ArrayHashSerializer

  validates :paper_type, presence: true
  validates :journal, presence: true

  validates :short_title, length: { maximum: 255 }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  delegate :admins, :editors, :reviewers, to: :journal, prefix: :possible

  def manuscript_id
    doi.split('/').last if doi
  end

  after_create :assign_doi!
  after_create :create_versioned_texts

  aasm column: :publishing_state do
    state :unsubmitted, initial: true # currently being authored
    state :submitted
    state :checking # small change that does not require resubmission, as in a tech check
    state :in_revision # has revised decision and requires resubmission
    state :accepted
    state :rejected
    state :published
    state :withdrawn

    event(:submit) do
      transitions from: [:unsubmitted, :in_revision],
                  to: :submitted,
                  guards: :metadata_tasks_completed?,
                  after: [:set_submitting_user_and_touch!,
                          :set_submitted_at!,
                          :prevent_edits!]
    end

    event(:minor_check) do
      transitions from: :submitted,
                  to: :checking,
                  after: [:allow_edits!,
                          :new_minor_version!]
    end

    event(:submit_minor_check) do
      transitions from: :checking,
                  to: :submitted,
                  after: [:set_submitting_user_and_touch!,
                          :prevent_edits!]
    end

    event(:minor_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!,
                          # there is a terminology mismatch here: it
                          # needs MINOR revision but we use a MAJOR
                          # version to track all papers send back
                          # after peer review.
                          :new_major_version!]
    end

    event(:major_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!,
                          :new_major_version!]
    end

    event(:accept) do
      transitions from: :submitted,
                  to: :accepted
    end

    event(:reject) do
      transitions from: :submitted,
                  to: :rejected
      before do
        update(active: false)
      end
    end

    event(:publish) do
      transitions from: :submitted,
                  to: :published,
                  after: :set_published_at!
    end

    event(:withdraw) do
      transitions to: :withdrawn,
                  after: :prevent_edits!
      before do |withdrawal_reason|
        update(active: false)
        withdrawals << { previous_publishing_state: publishing_state,
                         previous_editable: editable,
                         reason: withdrawal_reason }
      end
    end

    event(:reactivate) do
      # AASM doesn't currently allow transitions to dynamic states, so this iterator
      # explicitly defines each transition
      Paper.aasm.states.map(&:name).each do |state|
        transitions from: :withdrawn, to: state, after: :set_editable!, if: Proc.new { previous_state_is?(state) }
      end
      before do
        update(active: true)
      end
    end
  end

  def previous_state_is?(event)
    withdrawals.last[:previous_publishing_state] == event.to_s
  end

  def make_decision(decision)
    public_send "#{decision.verdict}!"
  end

  def body
    @new_body || latest_version.text
  end

  def body=(new_body)
    # We have an issue here. the first version is created on
    # after_create (because it needs the paper_id). But if this is
    # called before creation, it will fail. Get around this by storing
    # the text in @new_body if there is no latest version
    if latest_version.nil?
      @new_body = new_body
    else
      latest_version.update(text: new_body)
    end
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
  def display_title(sanitized: true)
    raw = (title.present? ? title : short_title).to_s # always return string
    sanitized ? strip_tags(raw) : raw.html_safe
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

  def latest_withdrawal_reason
    withdrawals.last[:reason] if withdrawals.present?
  end

  def resubmitted?
    decisions.pending.exists?
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
      "#{index + 1}. #{author.last_name}, #{author.first_name} from #{author.affiliation}"
    }.join("\n")
  end

  def latest_version(reload=false)
    versioned_texts(reload).version_desc.first
  end

  def apex_metadata

    # Desired Outcome (from JIRA)
    # ===============
    # Aperta needs to be able to include a JSON metadata export as part of the export package it sends to Apex, or other typesetters. This metadata is used to typeset parts of the article that cannot be derived directly from the manuscript file. The JSON metadata export should be a single file.
    # metadata fields to include
    #
    # short-title
    # doi (i.e. 10.1371/journal.pone.1234567)
    # ms-id (i.e. pone.1234567)
    # article-title
    # author-contrib (author contributions - last two might just be the JSON representation of the author card)
    # Corresponding Author - this should be the creating author, unless they've selected someone else on on the Add Authors card using the tick-box. It's okay if they've selected more than one person using as the CA using the tick-box
    # editor-contrib (the Academic Editor)
    # copyright-statement - keyed off of govt employee
    # -On Publishing Related Questions Card: If they do NOT select that authors are govt employees, than the standard copyright statement is sent
    # On Publishing Related Questions Card: If they DO select that authors are govt employees, send special copyright statement
    # financial disclosure card json
    # data availability statement
    # Conflict of interest statement
    # received-date (submission)
    # accepted date (“Register Decision” of Accept)
    # journal-title
    # *pub-date (production metadata card)
    # subj-group@subj-group-type=“ArticleType” (corresponds to workflow template)
    # supporting info card data p(only include files marked as 'for publication')


    doi_suffix = doi.split('/')[-1].split('.')
    ms_id = [doi_suffix[-2], doi_suffix[-1]].join('.')

    author_contrib = authors.map{|author| _author_hash(author)}

    metadata_hash = {
      short_title: short_title,
      doi: doi,
      ms_id: ms_id, #to be filled in below
      article_title: title,
      authors: author_contrib,
      # corrisponding_author: corrisponding_author, # note: this is a bool on author
      editor: _editor_hash(editor),
      copyright_statement: nil,
      financial_disclosure: _financial_disclosure_hash,
      data_availabliity_statement: nil,
      conflict_of_interest_statement: nil,
      received_date: nil,
      accepted_date: nil,
      journal_title: nil,
      publication_date: nil,
      # subj-group@subj-group-type=“ArticleType” #not sure what this means
      supporting_information_files: nil
    }
    return metadata_hash

  end

  private

  def new_major_version!
    latest_version.new_major_version!
  end

  def new_minor_version!
    latest_version.new_minor_version!
  end

  def default_abstract
    Nokogiri::HTML(body).text.truncate_words 100
  end

  def set_editable!
    update!(editable: withdrawals.last[:previous_editable])
  end

  def set_published_at!
    update!(published_at: Time.current.utc)
  end

  def set_submitted_at!
    update!(submitted_at: Time.current.utc)
  end

  def set_submitting_user_and_touch!(submitting_user) # rubocop:disable Style/AccessorMethodName
    latest_version.update!(submitting_user: submitting_user)
    latest_version.touch
  end

  def download_supporting_information
    return if supporting_information_files.empty?

    supporting_information = "<h2>Supporting Information</h2>"
    supporting_information_files.each do |file|
      if file.preview_src
        supporting_information.concat "<p>#{file.download_link file.preview_image}</p>"
      end
      supporting_information.concat "<p>#{file.download_link}</p>"
    end

    supporting_information
  end

  def assign_doi!
    self.update!(doi: DoiService.new(journal: journal).next_doi!) if journal
  end


  def _financial_disclosure_hash
    if financial_disclosure
      f_dis = financial_disclosure.answer_for("author_received_funding").value
      our_hash = {
        author_received_funding: f_dis
      }
      if f_dis
        our_hash[:funders] = financial_disclosure.funders.map do |funder|

          influence = begin
            if temp = funder.answer_for('funder_had_influence')
              temp.value
            end
          end

          influence_description = begin
            if temp = funder.answer_for('funder_had_influence.funder_role_description')
              temp.value
            end
          end
          {
            name: funder.name,
            grant_number: funder.grant_number,
            website: funder.website,
            funder_had_influence: influence,
            funder_influence_description: influence_description
          }

        end
      end

    end
  end

  def _editor_hash(editor)
    return unless editor
    affiliation = editor.affiliations.first
    {
      first_name: editor.first_name,
      last_name: editor.last_name,
      middle_initial: editor.middle_initial,
      email: editor.email,
      department: affiliation.department,
      title: affiliation.title,
      corresponding: editor.corresponding
    }
  end

  def _author_hash(author)
    {
      first_name: author.first_name,
      last_name: author.last_name,
      middle_initial: author.middle_initial,
      email: author.email,
      department: author.department,
      title: author.title,
      corresponding: author.corresponding,
      deceased: author.deceased,
      affiliation: author.affiliation,
      secondary_affiliation: author.secondary_affiliation,
      contributions: author.contributions.map(&:nested_question).map(&:text),
      ringgold_id: author.ringgold_id,
      secondary_ringgold_id: author.secondary_ringgold_id
    }
  end

  def create_versioned_texts
    versioned_texts.create!(major_version: 0, minor_version: 0, text: (@new_body || ''))
  end
end
