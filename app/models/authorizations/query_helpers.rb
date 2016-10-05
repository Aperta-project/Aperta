module Authorizations
  module QueryHelpers
    def table
      @table ||= {
        roles: Role.arel_table,
        permissions_roles: Arel::Table.new(Role.reflections['permissions'].join_table),
        permissions: Permission.arel_table,
        permission_requirements: PermissionRequirement.arel_table,
        permission_states_permissions: Arel::Table.new(Permission.reflections['states'].join_table),
        permission_states: PermissionState.arel_table,
        results: Arel::Table.new(:results),
        results_with_permissions: Arel::Table.new(:results_with_permissions)
      }
    end

    # Our version of Arel won't let us union more than two things. So we get around that.
    def union(*args)
      if args.length == 1 && args.first.is_a?(Array)
        first = args.first.first
        list = args.first[1..-1]
      elsif args.length == 1
        first = args.first
        list = []
        # we have a single arel node with no list?
      elsif args.length == 2
        first = args.first
        list = args.last
      else
        fail "I don't know what's going on"
      end

      if list.blank?
        return first
      elsif list.count == 1
        return first.union(list.first)
      else
        return Arel::Nodes::Union.new(first, union(list.first, list[1..-1]))
      end
    end
  end
end
