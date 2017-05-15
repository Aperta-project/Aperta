module Authorizations
  # PermissionDefinition represents a definition of a permission in
  # memory. It is used in the process of building up
  # Authorization::RoleDefinition(s) for efficient database importing.
  class PermissionDefinition
    attr_reader :action, :applies_to, :states

    def initialize(action:, applies_to:, states:)
      @action = action.to_s
      @applies_to = applies_to
      @states = states.uniq
    end
  end
end
