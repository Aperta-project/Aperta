class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :states, class_name: 'PermissionState'

  def self.ensure(action, applies_to:, role: nil, states: ['*'])
    perm = Permission.where(action: action, applies_to: applies_to.to_s)
           .first_or_create!
    role.permissions = (role.permissions | [perm]) unless role.nil?
    perm.states = (perm.states |
                   states.map do |state_name|
                     PermissionState.where(name: state_name).first_or_create!
                   end)
    perm
  end
end
