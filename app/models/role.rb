class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  ACADEMIC_EDITOR_ROLE = 'Academic Editor'
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
  STAFF_ADMIN_ROLE = 'Staff Admin'
  TASK_PARTICIPANT_ROLE = 'Participant'
  USER_ROLE = 'User'
  REVIEWER_REPORT_OWNER_ROLE = "Reviewer Report Owner"

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
    # This should never change.
    @user_role || Role.find_by(name: Role::USER_ROLE)
  end

  def self.ensure_exists(name, journal: nil,
                               participates_in: [],
                               delete_stray_permissions: true,
                         &block)
    role = Role.where(name: name, journal: journal).first_or_create!

    # Ensure user passed in valid participates_in
    whitelist = [Task, Paper]
    fail StandardError, "Bad participates_in: #{participates_in}" unless \
      ((whitelist | participates_in) == whitelist)

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
