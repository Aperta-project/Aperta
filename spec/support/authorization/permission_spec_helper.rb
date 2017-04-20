class PermissionSpecHelper
  def self.create_permissions(label=nil, &blk)
    new(label, &blk).permissions
  end

  def self.create_permission(label, action:, applies_to:, states:, **kwargs)
    new(label).permission(action: action, applies_to: applies_to, states: states, **kwargs)
  end

  attr_reader :permissions

  def initialize(label, &blk)
    @label = label
    @permissions = []
    instance_exec &blk if blk
    self
  end

  def permission(action:, applies_to:, states: ['*'], **kwargs)
    states = states.map { |state_name| PermissionState.where(name: state_name).first_or_create! }
    perm = Permission.ensure_exists(action, applies_to: applies_to, states: states, **kwargs)
    @permissions.push perm
    perm
  end
end
