class RoleSpecHelper
  def self.create_role(name, participates_in: [], &blk)
    new(name, participates_in: participates_in, &blk).role
  end

  attr_reader :role

  def initialize(name, participates_in: [], &blk)
    @name = name

    attrs = participates_in.reduce({}) do |hsh, klass|
      column = "participates_in_#{klass.name.underscore.downcase.pluralize}"
      hsh[column] = true
      hsh
    end

    @role = FactoryGirl.create(:role, attrs.merge(name: name))
    instance_exec &blk if blk
    self
  end

  def has_permission(action:, applies_to:)
    @role.permissions |= [Permission.find_by_action_and_applies_to!(action, applies_to)]
    @role
  end
end
