class User < ActiveRecord::Base
  include Assignable::User
  include UserHelper
  include UserDevise

  include PgSearch
  pg_search_scope \
    :fuzzy_search,
    against: [:first_name, :last_name, :email, :username],
    ignoring: :accents,
    using: { tsearch: { prefix: true }, trigram: { threshold: 0.3 } }

  has_many :affiliations, inverse_of: :user

  has_many :paper_roles
  has_many :papers, -> { uniq }, through: :paper_roles
  has_many :user_roles, inverse_of: :user
  has_many :old_roles, through: :user_roles
  has_many(
    :journals_thru_old_roles,
    -> { uniq },
    through: :old_roles,
    source: :journal
  )
  has_many :comments, inverse_of: :commenter, foreign_key: 'commenter_id'
  has_many \
    :participations,
    -> { joins(:role).where(roles: { name: Role::TASK_PARTICIPANT_ROLE }) },
    class_name: 'Assignment',
    inverse_of: :user
  has_many \
    :tasks,
    lambda {
      joins(assignments: :role)
        .where(roles: { name: Role::TASK_PARTICIPANT_ROLE })
    },
    through: :assignments,
    source: :assigned_to,
    source_type: 'Task'
  has_many :comment_looks, inverse_of: :user
  has_many :credentials, inverse_of: :user, dependent: :destroy
  has_many \
    :assigned_papers,
    -> { uniq },
    through: :paper_roles,
    class_name: 'Paper',
    source: :paper
  has_many :invitations, foreign_key: :invitee_id, inverse_of: :invitee
  has_many :invitations_from_me, foreign_key: :inviter_id, inverse_of: :inviter
  has_many \
    :discussion_replies,
    foreign_key: :replier_id,
    inverse_of: :replier,
    dependent: :destroy
  has_many :discussion_participants, inverse_of: :user, dependent: :destroy
  has_many :discussion_topics, through: :discussion_participants
  has_many :notifications, inverse_of: :paper

  attr_accessor :login

  validates \
    :username,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 255 }
  validates :email, format: Devise.email_regexp
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }

  validates :ned_id, uniqueness: true, allow_nil: true
  validates_with NedValidator

  mount_uploader :avatar, AvatarUploader

  after_create :add_user_role!, :associate_invites

  if Rails.configuration.password_auth_enabled
    devise(
      :trackable, :omniauthable, :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable,
      authentication_keys: [:login],
      omniauth_providers: Rails.configuration.omniauth_providers
    )
  else
    devise(
      :trackable, :omniauthable,
      omniauth_providers: Rails.configuration.omniauth_providers
    )
  end

  # This associates existing invites to newly created users.
  # Existing users have their invitations associated upon the creation of the
  # invitation. See invitation.rb
  def associate_invites
    Invitation.where_email_matches(email)
      .where(invitee: nil)
      .update_all(invitee_id: id)
  end

  def created_papers_for_journal(journal)
    Paper.assignments_for(user: self, role: journal.creator_role)
  end

  def password_required?
    Rails.configuration.password_auth_enabled && super
  end

  def self.site_admins
    where(site_admin: true)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def auto_generate_password(length=50)
    self.password = SecureRandom.urlsafe_base64(length-1) if password_required?
  end

  def journal_admin?(journal)
    administered_journals.include? journal
  end

  # Returns the journals that this user administers. If you pass a block
  # this will yield an ActiveRecord::Relation query object that you can
  # use to put further conditions on.
  def administered_journals(&blk)
    journal_query = Journal.all
    journal_query = blk.call(journal_query) if block_given?
    if site_admin?
      journal_query
    else
      filter_authorized(:administer, journal_query).objects
    end
  end

  def accessible_journals
    site_admin? ? Journal.all : journals_thru_old_roles
  end

  def invitations_from_latest_revision
    # Includes, here, to enable selecting from the latest revision w/o
    # further db queries.
    invitations.includes([{ decision: [:paper] }, :paper]).select do |invitation|
      invitation.decision && invitation.decision.latest?
    end
  end

  def self.assigned_to_journal(journal_id)
    joins(:assignments)
      .where("assignments.assigned_to_type = 'Journal'")
      .where('assignments.assigned_to_id = ?', journal_id)
      .reorder("last_name", "first_name")
      .uniq
  end

  def self.search_users(query)
    sanitized_query = connection.quote_string(query.to_s.downcase) + '%'
    User.fuzzy_search sanitized_query
  end

  def add_user_role!
    return unless Role.user_role
    assign_to!(assigned_to: self, role: Role.user_role)
  end
end
