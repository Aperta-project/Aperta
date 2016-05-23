class Journal < ActiveRecord::Base
  has_many :billing_logs
  has_many :papers, inverse_of: :journal
  has_many :tasks, through: :papers, inverse_of: :journal
  has_many :roles, inverse_of: :journal
  has_many :assignments, as: :assigned_to
  has_many :discussion_topics, through: :papers, inverse_of: :journal

  # Old Roles and Permissions
  has_many :old_roles, inverse_of: :journal
  has_many :user_roles, through: :old_roles
  has_many :users, through: :user_roles

  has_many :manuscript_manager_templates, dependent: :destroy
  has_many :journal_task_types, inverse_of: :journal, dependent: :destroy

  validates :name, presence: { message: 'Please include a journal name' }
  validates :doi_journal_prefix, uniqueness: {
    scope: [:doi_publisher_prefix],
    if: proc { |journal|
      journal.doi_journal_prefix.present? && journal.doi_publisher_prefix.present?
    }
  }
  validate :has_valid_doi_information?

  after_create :setup_defaults
  before_destroy :confirm_no_papers, prepend: true
  before_destroy :destroy_roles

  mount_uploader :logo,       LogoUploader
  mount_uploader :epub_cover, EpubCoverUploader

  # rubocop:disable Metrics/LineLength
  has_one :academic_editor_role, -> { where(name: Role::ACADEMIC_EDITOR_ROLE) },
          class_name: 'Role'
  has_one :creator_role, -> { where(name: Role::CREATOR_ROLE) },
          class_name: 'Role'
  has_one :collaborator_role, -> { where(name: Role::COLLABORATOR_ROLE) },
          class_name: 'Role'
  has_one :cover_editor_role, -> { where(name: Role::COVER_EDITOR_ROLE) },
          class_name: 'Role'
  has_one :discussion_participant_role, -> { where(name: Role::DISCUSSION_PARTICIPANT) },
          class_name: 'Role'
  has_one :freelance_editor_role, -> { where(name: Role::FREELANCE_EDITOR_ROLE) },
          class_name: 'Role'
  has_one :internal_editor_role, -> { where(name: Role::INTERNAL_EDITOR_ROLE) },
          class_name: 'Role'
  has_one :handling_editor_role, -> { where(name: Role::HANDLING_EDITOR_ROLE) },
          class_name: 'Role'
  has_one :production_staff_role, -> { where(name: Role::PRODUCTION_STAFF_ROLE) },
          class_name: 'Role'
  has_one :publishing_services_role, -> { where(name: Role::PUBLISHING_SERVICES_ROLE) },
          class_name: 'Role'
  has_one :reviewer_role, -> { where(name: Role::REVIEWER_ROLE) },
          class_name: 'Role'
  has_one :reviewer_report_owner_role, -> { where(name: Role::REVIEWER_REPORT_OWNER_ROLE) },
          class_name: 'Role'
  has_one :staff_admin_role, -> { where(name: Role::STAFF_ADMIN_ROLE) },
          class_name: 'Role'
  has_one :task_participant_role, -> { where(name: Role::TASK_PARTICIPANT_ROLE) },
          class_name: 'Role'
  has_one :user_role, -> { where(name: Role::USER_ROLE, journal_id: nil) },
          class_name: 'Role'
  # rubocop:enable Metrics/LineLength

  def admins
    users.merge(OldRole.admins)
  end

  def reviewers
    users.merge(OldRole.reviewers)
  end

  def logo_url
    logo.thumbnail.url if logo
  end

  def epub_cover_file_name
    return nil unless epub_cover.file

    if Rails.application.config.carrierwave_storage == :fog
      URI(epub_cover.file.url).path.split('/').last
    else
      epub_cover.file.filename
    end
  end

  def epub_cover_url
    epub_cover.url if epub_cover
  end

  def paper_types
    self.manuscript_manager_templates.pluck(:paper_type)
  end

  def valid_old_roles
    PaperRole::ALL_ROLES | old_roles.map(&:name)
  end

  # Try to block other services from directly updating last_doi_issued to avoid
  # issues where last_doi_issued gets out-of-sync.
  # instead those services should call #next_doi_number!
  def last_doi_issued=(*args)
    return unless new_record?
    super(*args)
  end

  def next_doi_number!
    with_lock do
      last_doi_issued.succ.tap do |next_number|
        update_column :last_doi_issued, next_number
      end
    end
  end

  private

  def has_valid_doi_information?
    ds = DoiService.new(journal: self)
    return unless ds.journal_has_doi_prefixes?
    return if ds.journal_doi_info_valid?
    errors.add(:doi, "The DOI you specified is not valid.")
  end

  def setup_defaults
    # TODO: remove these from being a callback (when we aren't using rails_admin)
    JournalServices::CreateDefaultRoles.call(self)
    JournalServices::CreateDefaultTaskTypes.call(self)
    JournalServices::CreateDefaultManuscriptManagerTemplates.call(self)
  end

  def destroy_roles
    # old_roles that are marked as 'required' are prevented from being destroyed, so you cannot use
    # a dependent_destroy on the AR relationship.
    self.mark_for_destruction
    old_roles.destroy_all
  end

  def confirm_no_papers
    if papers.any?
      message = "journal has #{papers.count} associated papers that must be destroyed first"
      errors.add(:base, message)
      false # prevent destruction
    end
  end
end
