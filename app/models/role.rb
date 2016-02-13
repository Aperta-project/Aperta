class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy

  CREATOR_ROLE = 'Creator'
  COLLABORATOR_ROLE = 'Collaborator'
  INTERNAL_EDITOR_ROLE = 'Internal Editor'
  HANDLING_EDITOR_ROLE = 'Handling Editor'
  PARTICIPANT_ROLE = 'Participant'
  PUBLISHING_SERVICES_ROLE = 'Publishing Services and Production Staff'
  REVIEWER_ROLE = 'Reviewer'
  STAFF_ADMIN_ROLE = 'Staff Admin'
  USER_ROLE = 'User'

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

  def self.ensure_exists(name, journal: nil, participates_in: [], &block)
    role = Role.where(name: name, journal: journal).first_or_create!

    # Ensure user passed in valid participates_in
    whitelist = [Task, Paper]
    fail StandardError, "Bad participates_in: #{participates_in}" unless \
      ((whitelist | participates_in) == whitelist)

    participates_in.each do |klass|
      role.update("participates_in_#{klass.to_s.downcase.pluralize}" => true)
    end
    yield(role) if block_given?
    role
  end

  def ensure_permission_exists(action, applies_to:, states: ['*'])
    Permission.ensure_exists(action, applies_to: applies_to, role: self,
                              states: states)
  end
end
