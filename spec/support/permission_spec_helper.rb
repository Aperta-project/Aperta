class PermissionSpecHelper
  def self.create_permissions(label = nil, context, &blk)
    new(label, context, &blk).permissions
  end

  def self.create_permission(label, context, action:, applies_to:, states:, filter_by_card_id: nil, **kwargs)
    new(label, context).permission(action: action,
                                   applies_to: applies_to,
                                   states: states,
                                   filter_by_card_id: filter_by_card_id,
                                   **kwargs)
  end

  attr_reader :permissions

  def initialize(label, context, &blk)
    @label = label
    @permissions = []
    instance_exec(context, &blk) if blk
    self
  end

  def permission(action:, applies_to:, states: ['*'], filter_by_card_id: nil, **kwargs)
    states = states.map { |state_name| PermissionState.where(name: state_name).first_or_create! }
    perm = Permission.ensure_exists(action,
                                    applies_to: applies_to,
                                    states: states,
                                    filter_by_card_id: filter_by_card_id,
                                    **kwargs)
    @permissions.push perm
    perm
  end
end
