module Authorizations
  module QueryHelpers
    # Returns an Arel::Node::As instance which aliases the given query
    # with the provided table_name.
    def reference_query_as_table(query, table_name)
      Arel::Nodes::As.new Arel::Table.new(table_name), query.to_arel
    end

    # Returns a Hash of names to Arel::Table instances for common table
    # references in the Authorizations sub-system.
    def table
      @table ||= {
        roles: Role.arel_table,
        permissible_assignments: Arel::Table.new(:permissible_assignments),
        permissions_roles: Arel::Table.new(Role.reflections['permissions'].join_table),
        permissions: Permission.arel_table,
        permission_states_permissions: Arel::Table.new(Permission.reflections['states'].join_table),
        permission_states: PermissionState.arel_table,
        results: Arel::Table.new(:results),
        results_with_permissions: Arel::Table.new(:results_with_permissions)
      }
    end

    # Arel doesn't provide a nice way to union more than two queries so
    # this method gets around that by accepting a list of Arel ASTs to
    # union.
    def union(list)
      raise ArgumentError unless list.is_a?(Array)
      list.reduce do |sofar, obj|
        Arel::Nodes::Union.new(sofar, obj)
      end
    end
  end
end
