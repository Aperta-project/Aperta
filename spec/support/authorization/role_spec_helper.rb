class RoleSpecHelper
  def self.create_role(name, &blk)
    new(name, &blk).role
  end

  attr_reader :role

  def initialize(name, &blk)
    @name = name
    @role = Role.ensure_exists(name)
    instance_exec &blk if blk
    self
  end

  def has_permission(action:, applies_to:)
    @role.permissions |= [Permission.find_by_action_and_applies_to!(action, applies_to)]
    @role
  end
end
