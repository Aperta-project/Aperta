class Journal < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable
  include Configurable

  PUBLISHER_PREFIX_FORMAT = /[\w\d\-\.]+/
  SUFFIX_FORMAT           = %r{journal[^\/]+}
  DOI_FORMAT              = %r{\A(#{PUBLISHER_PREFIX_FORMAT}/#{SUFFIX_FORMAT})\z}
  SHORT_DOI_FORMAT        = /[a-zA-Z0-9]+\.[0-9]+/

  class InvalidDoiError < ::StandardError; end

  has_many :papers, inverse_of: :journal
  has_many :tasks, through: :papers, inverse_of: :journal
  has_many :cards, inverse_of: :journal
  has_many :card_versions, through: :cards, inverse_of: :journal
  has_many :roles, inverse_of: :journal
  has_many :assignments, as: :assigned_to
  has_many :discussion_topics, through: :papers, inverse_of: :journal
  has_many :letter_templates, -> { where.not(scenario: TemplateContext.feature_inactive_scenarios) }

  has_many :manuscript_manager_templates, dependent: :destroy
  has_many :journal_task_types, inverse_of: :journal, dependent: :destroy
  has_many :behaviors, inverse_of: :journal, dependent: :destroy

  validates :name, presence: { message: 'Please include a journal name' }, uniqueness: true
  validates :doi_publisher_prefix,
    presence: { message: 'Please include a DOI Publisher Prefix' },
    format: {
      with: PUBLISHER_PREFIX_FORMAT,
      message: 'The DOI Publisher Prefix is not valid. It can only contain word characters, numbers, -, and .',
      if: proc { |journal| journal.doi_publisher_prefix.present? }
    }
  validates :doi_journal_prefix,
    presence: { message: 'Please include a DOI Journal Prefix' },
    format: {
      with: SUFFIX_FORMAT,
      message: 'The DOI Journal Prefix is not valid. It must begin with \'journal\' and can contain any characters except /',
      if: proc { |journal| journal.doi_journal_prefix.present? }
    },
    uniqueness: { scope: :doi_publisher_prefix,
                  message: 'This DOI Journal Prefix has already been assigned to this publisher.  Please choose a unique DOI Journal Prefix' }
  validates :last_doi_issued, presence: { message: 'Please include a Last DOI Issued' }

  before_destroy :confirm_no_papers, prepend: true

  mount_uploader :logo, LogoUploader
  has_one :academic_editor_role, -> { where(name: Role::ACADEMIC_EDITOR_ROLE) },
    class_name: 'Role'
  has_one :billing_role, -> { where(name: Role::BILLING_ROLE) },
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
  has_one :journal_setup_role, -> { where(name: Role::JOURNAL_SETUP_ROLE) },
    class_name: 'Role'
  has_one :user_role, -> { where(name: Role::USER_ROLE, journal_id: nil) },
    class_name: 'Role'
  # rubocop:enable Metrics/LineLength

  def user_can_view?(_user)
    # Any user can view a journal.
    true
  end

  def setting_template_key
    'Journal'
  end

  def self.staff_admins_for_papers(papers)
    journals = joins(:papers)
               .where(papers: { id: papers })
    journals.flat_map(&:staff_admins)
  end

  def self.staff_admins_across_all_journals
    all.flat_map(&:staff_admins)
  end

  def self.valid_doi?(doi)
    !!(doi =~ DOI_FORMAT)
  end

  def active_cards
    cards.active
  end

  # Per https://confluence.plos.org/confluence/display/FUNC/DOI+Guidelines
  def doi_journal_abbrev
    doi_journal_prefix.split('.').last
  end

  def staff_admins
    User.with_role(staff_admin_role, assigned_to: self)
  end

  def logo_url
    if logo
      logo.thumbnail.url
    else
      '/images/plos_logo.png'
    end
  end

  def paper_types
    # We ordering by the oldest articles first to have 'Research Article'
    # to float to the top of the article drop down list
    manuscript_manager_templates.order('id asc').pluck(:paper_type)
  end

  # Try to block other services from directly updating last_doi_issued to avoid
  # issues where last_doi_issued gets out-of-sync.
  # instead those services should call #next_doi!
  def last_doi_issued=(*args)
    return unless new_record?
    super(*args)
  end

  # Returns the next DOI string for this journal incrementing the
  # last_doi_issued column in the process
  def next_doi!
    with_lock do
      next_number = last_doi_issued.succ
      next_doi = "#{doi_publisher_prefix}/#{doi_journal_prefix}.#{next_number}"
      if self.class.valid_doi?(next_doi)
        update_column :last_doi_issued, next_number
        return next_doi
      else
        raise InvalidDoiError, "Attempted to generate the next DOI, but it was in an invalid DOI format: #{next_doi}"
      end
    end
  end

  private

  def confirm_no_papers
    if papers.any?
      message = "journal has #{papers.count} associated papers that must be destroyed first"
      errors.add(:base, message)
      false # prevent destruction
    end
  end
end
