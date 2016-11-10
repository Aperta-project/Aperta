class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  ACADEMIC_EDITOR_ROLE = 'Academic Editor'
  BILLING_ROLE = 'Billing Staff'
  COLLABORATOR_ROLE = 'Collaborator'
  COVER_EDITOR_ROLE = 'Cover Editor'
  CREATOR_ROLE = 'Creator'
  DISCUSSION_PARTICIPANT = 'Discussion Participant'
  FREELANCE_EDITOR_ROLE = 'Freelance Editor'
  HANDLING_EDITOR_ROLE = 'Handling Editor'
  INTERNAL_EDITOR_ROLE = 'Internal Editor'
  PRODUCTION_STAFF_ROLE = 'Production Staff'
  PUBLISHING_SERVICES_ROLE = 'Publishing Services'
  REVIEWER_ROLE = 'Reviewer'
  SITE_ADMIN_ROLE = 'Site Admin'
  STAFF_ADMIN_ROLE = 'Staff Admin'
  TASK_PARTICIPANT_ROLE = 'Participant'
  USER_ROLE = 'User'
  REVIEWER_REPORT_OWNER_ROLE = 'Reviewer Report Owner'

  # These roles (user, discussion topic, task) are automatically
  # assigned by the system
  USER_ROLES = [USER_ROLE]

  DISCUSSION_TOPIC_ROLES = [DISCUSSION_PARTICIPANT]

  TASK_ROLES = [
    REVIEWER_REPORT_OWNER_ROLE,
    TASK_PARTICIPANT_ROLE
  ]

  # Paper and Journal roles are set explicitly
  PAPER_ROLES = [
    ACADEMIC_EDITOR_ROLE,
    COLLABORATOR_ROLE,
    COVER_EDITOR_ROLE,
    CREATOR_ROLE,
    HANDLING_EDITOR_ROLE,
    REVIEWER_ROLE
  ]

  JOURNAL_ROLES = [
    FREELANCE_EDITOR_ROLE,
    INTERNAL_EDITOR_ROLE,
    PRODUCTION_STAFF_ROLE,
    PUBLISHING_SERVICES_ROLE,
    STAFF_ADMIN_ROLE
  ]

  def self.for_old_role(old_role, paper:) # rubocop:disable Metrics/MethodLength
    case old_role
    when /^admin$/i then paper.journal.staff_admin_role
    when /^editor$/i then paper.journal.handling_editor_role
    when /^collaborator$/i then paper.journal.collaborator_role
    when /^reviewer$/i then paper.journal.reviewer_role
    else
      fail NotImplementedError, <<-MSG.strip_heredoc
        Not sure how to match up old role '#{old_role}' with a new role.
        Do no fret though. This just needs to be implemented until we are
        done migrating away from the old roles.
      MSG
    end
  end

  def self.user_role
    find_by(name: Role::USER_ROLE, journal: nil)
  end

  def self.site_admin_role
    find_by(name: Role::SITE_ADMIN_ROLE, journal: nil)
  end

  def self.ensure_exists(*args, &blk)
    Authorizations::RoleDefinition.ensure_exists(*args, &blk)
  end

  def ensure_permission_exists(action, applies_to:, role: nil, states: [Permission::WILDCARD])
    Permission.ensure_exists(
      action,
      applies_to: applies_to,
      role: self,
      states: states
    )
  end
end
