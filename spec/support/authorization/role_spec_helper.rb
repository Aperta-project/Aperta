class RoleSpecHelper
  def self.create_role(name, context, journal:, participates_in: [], &blk)
    new(name, context, journal: journal, participates_in: participates_in, &blk).role
  end

  attr_reader :role

  def initialize(name, context, journal: nil, participates_in: [], &blk)
    @name = name
    @journal = journal || FactoryGirl.create(:journal)

    attrs = participates_in.each_with_object({}) do |klass, hsh|
      column = "participates_in_#{klass.name.underscore.downcase.pluralize}"
      hsh[column] = true
    end

    @role = FactoryGirl.create(:role, attrs.merge(name: name, journal: journal))
    instance_exec(context, &blk) if blk
    self
  end

  def has_permission(action:, applies_to:, states: ['*'], **kwargs)
    permissions = Permission.includes(:states).where(
      action: action,
      applies_to: applies_to,
      **kwargs
    ).select do |permission|
      permission.states.map(&:name).map(&:to_s).sort == states.map(&:to_s).sort
    end
    if permissions.empty?
      raise <<-MSG.strip_heredoc
        Permission not found for action=#{action} applies_to=#{applies_to}
        with the following states: #{states.inspect}

        The calling spec may not be defining the permission. Make sure you
        declare the permission for the action, applies_to, and all of the states
        that you're intending to give a role. E.g.:

          permission(
            action: '#{action}',
            applies_to: #{applies_to},
            states: #{states.inspect}
          )
      MSG
    end
    @role.permissions |= permissions
    @role
  end
end
