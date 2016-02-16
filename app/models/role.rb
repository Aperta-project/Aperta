class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy

  ACADEMIC_EDITOR_ROLE = 'Academic Editor'
  COLLABORATOR_ROLE = 'Collaborator'
  CREATOR_ROLE = 'Creator'
  HANDLING_EDITOR_ROLE = 'Handling Editor'
  INTERNAL_EDITOR_ROLE = 'Internal Editor'
  PARTICIPANT_ROLE = 'Participant'
  PUBLISHING_SERVICES_ROLE = 'Publishing Services and Production Staff'
  REVIEWER_ROLE = 'Reviewer'
  STAFF_ADMIN_ROLE = 'Staff Admin'
  USER_ROLE = 'User'

  def self.creator
    where(name: CREATOR_ROLE).first_or_create!
  end

  def self.collaborator
    where(name: COLLABORATOR_ROLE).first_or_create!
  end

  def self.internal_editor
    where(name: INTERNAL_EDITOR_ROLE).first_or_create!
  end

  def self.handling_editor
    where(name: HANDLING_EDITOR_ROLE).first_or_create!
  end

  def self.participant
    where(name: PARTICIPANT_ROLE).first_or_create!
  end

  def self.publishing_services
    where(name: PUBLISHING_SERVICES_ROLE)
  end

  def self.reviewer
    where(name: REVIEWER_ROLE).first_or_create!
  end

  def self.staff_admin
    where(name: STAFF_ADMIN_ROLE).first_or_create!
  end

  def self.academic_editor
    where(name: ACADEMIC_EDITOR_ROLE).first_or_create!
  end

  def self.user
    where(name: USER_ROLE, journal_id: nil).first_or_create!
  end

  def self.for_old_role(old_role, paper:) # rubocop:disable Metrics/MethodLength
    case old_role
    when /^admin$/i then paper.journal.roles.staff_admin
    when /^editor$/i then paper.journal.roles.handling_editor
    when /^collaborator$/i then paper.journal.roles.collaborator
    when /^reviewer$/i then paper.journal.roles.reviewer
    else
      fail NotImplementedError, <<-MSG.strip_heredoc
        Not sure how to match up old role '#{old_role}' with a new role.
        Do no fret though. This just needs to be implemented until we are
        done migrating away from the old roles.
      MSG
    end
  end

  def self.ensure_exists(name, journal: nil,
                               participates_in: [],
                               delete_stray_permissions: false,
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
    @ensured_permission_ids << perm.id
    perm
  end

  private

  def reset_tracked_permissions
    @ensured_permission_ids = []
  end

  def delete_stray_permissions
    fail StandardError, "Role.ensure_exists called with
delete_stray_permissions, but no permissions created." \
                        if @ensured_permission_ids.blank?
    permissions.delete(permissions.where.not(id: @ensured_permission_ids))
    reset_tracked_permissions
  end
end
