class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :states, class_name: 'PermissionState'

  after_save do
    User.find_each.each(&:expire_cache_key)
  end

  def self.ensure_exists(action, applies_to:, role: nil, states: ['*'])
    permission_states = states.map do |state|
      if state.is_a?(PermissionState)
        state
      else
        PermissionState.where(name: state).first_or_create!
      end
    end
    permission_states_ids = permission_states.map(&:id)
    perm = Permission.includes(:states).where(action: action,
                                              applies_to: applies_to.to_s,
                                              permission_states: {
                                                id: permission_states_ids
                                              })
           .first_or_create!
    perm.states = permission_states
    role.permissions = (role.permissions | [perm]) unless role.nil?
    perm
  end
end
