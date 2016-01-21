class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions

  AUTHOR_ROLE = 'Author'
  REVIEWER_ROLE = 'Reviewer'
  INTERNAL_EDITOR_ROLE = 'Internal Editor'
  STAFF_ADMIN_ROLE = 'Staff Admin'

  def self.author
    where(name: AUTHOR_ROLE).first_or_create!
  end

  def self.internal_editor
    where(name: INTERNAL_EDITOR_ROLE).first_or_create!
  end

  def self.reviewer
    where(name: REVIEWER_ROLE).first_or_create!
  end

  def self.staff_admin
    where(name: STAFF_ADMIN_ROLE).first_or_create!
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
