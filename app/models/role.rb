class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  ACADEMIC_EDITOR_ROLE = 'Academic Editor'.freeze
  BILLING_ROLE = 'Billing Staff'.freeze
  COLLABORATOR_ROLE = 'Collaborator'.freeze
  COVER_EDITOR_ROLE = 'Cover Editor'.freeze
  CREATOR_ROLE = 'Creator'.freeze
  DISCUSSION_PARTICIPANT = 'Discussion Participant'.freeze
  FREELANCE_EDITOR_ROLE = 'Freelance Editor'.freeze
  HANDLING_EDITOR_ROLE = 'Handling Editor'.freeze
  INTERNAL_EDITOR_ROLE = 'Internal Editor'.freeze
  PRODUCTION_STAFF_ROLE = 'Production Staff'.freeze
  PUBLISHING_SERVICES_ROLE = 'Publishing Services'.freeze
  REVIEWER_ROLE = 'Reviewer'.freeze
  SITE_ADMIN_ROLE = 'Site Admin'.freeze
  STAFF_ADMIN_ROLE = 'Staff Admin'.freeze
  TASK_PARTICIPANT_ROLE = 'Participant'.freeze
  USER_ROLE = 'User'.freeze
  REVIEWER_REPORT_OWNER_ROLE = 'Reviewer Report Owner'.freeze

  # These roles (user, discussion topic, task) are automatically
  # assigned by the system
  USER_ROLES = [USER_ROLE].freeze

  DISCUSSION_TOPIC_ROLES = [DISCUSSION_PARTICIPANT].freeze

  TASK_ROLES = [
    REVIEWER_REPORT_OWNER_ROLE,
    TASK_PARTICIPANT_ROLE
  ].freeze

  # Paper and Journal roles are set explicitly
  PAPER_ROLES = [
    ACADEMIC_EDITOR_ROLE,
    COLLABORATOR_ROLE,
    COVER_EDITOR_ROLE,
    CREATOR_ROLE,
    HANDLING_EDITOR_ROLE,
    REVIEWER_ROLE
  ].freeze

  JOURNAL_ROLES = [
    FREELANCE_EDITOR_ROLE,
    INTERNAL_EDITOR_ROLE,
    PRODUCTION_STAFF_ROLE,
    PUBLISHING_SERVICES_ROLE,
    STAFF_ADMIN_ROLE
  ].freeze

  def self.user_role
    find_by(name: Role::USER_ROLE, journal: nil)
  end

  def self.site_admin_role
    find_by(name: Role::SITE_ADMIN_ROLE, journal: nil)
  end

  def self.ensure_exists(name, journal: nil,
    participates_in: [],
    delete_stray_permissions: true)
    role = Role.where(name: name, journal: journal).first_or_create!

    # Ensure user passed in valid participates_in
    whitelist = [Task, Paper]
    raise StandardError, "Bad participates_in: #{participates_in}" unless \
      (whitelist | participates_in) == whitelist

    participates_in.each do |klass|
      role.update("participates_in_#{klass.to_s.downcase.pluralize}" => true)
    end

    role.send(:reset_tracked_permissions)
    yield(role) if block_given?
    role.send(:delete_stray_permissions) if delete_stray_permissions
    role
  end

  def ensure_permission_exists(action, applies_to:, states: ['*'])
    perm = Permission.ensure_exists(action, applies_to: applies_to, role: self,
                                            states: states)
    ensured_permission_ids << perm.id
    perm
  end

  private

  def ensured_permission_ids
    @ensured_permission_ids ||= []
  end

  def reset_tracked_permissions
    @ensured_permission_ids = []
  end

  def delete_stray_permissions
    return if ensured_permission_ids.empty?
    permissions.delete(permissions.where.not(id: ensured_permission_ids))
    reset_tracked_permissions
  end
end
