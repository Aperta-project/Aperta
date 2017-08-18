module Authorizations
  class ObjectsPermissibleByRequiredPermissionsQuery
    include QueryHelpers

    attr_reader :assignments_table, :auth_config, :common_query,
      :klass, :objects_query, :target

    def initialize(klass:, assignments_table:, objects_query:)
      @klass = klass
      @assignments_table = assignments_table
      @objects_query = objects_query
    end

    def to_arel
      query = add_permissions_column_to_assignments
      add_permission_states(query)
      query.group(table[:results][:id])
    end

    def to_sql
      to_arel.to_sql
    end

    private

    def permission_actions_column
      Arel.sql("string_agg(distinct(concat(permissions.action::text, ':', permission_states.name::text)), ', ') AS permission_actions")
    end

    def add_permissions_column_to_assignments
      Arel::SelectManager.new(klass.arel_table.engine).
        with(assignments_table).
        project(
          table[:results][:id],
          permission_actions_column
        ).from(Arel.sql('(' + objects_query.to_sql + ')')
                 .as(table[:results].table_name))
    end

    def add_permission_states(query)
      query.join(table[:permissions]).on(
        table[:permissions][:id].eq(table[:results][:permission_id])
      ).join(table[:permission_states_permissions]).on(
        table[:permission_states_permissions][:permission_id].eq(table[:permissions][:id])
      ).join(table[:permission_states]).on(
        table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
      )
    end
  end
end
