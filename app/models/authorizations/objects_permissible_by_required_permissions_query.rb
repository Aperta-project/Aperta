module Authorizations
  class ObjectsPermissibleByRequiredPermissionsQuery
    include QueryHelpers
    attr_reader :klass, :assignments_table, :objects_query, :applies_to

    def initialize klass:, assignments_table:, objects_query:, applies_to:
      @klass = klass
      @assignments_table = assignments_table
      @objects_query = objects_query
      @applies_to = applies_to
    end

    def to_arel
      Arel::SelectManager.new(klass.arel_table.engine).
        with(assignments_table).
        project(
          table[:results][:id],
          Arel.sql("string_agg(distinct(concat(permissions.action::text, ':', permission_states.name::text)), ', ') AS permission_actions"),
        ).
        from( Arel.sql('(' + objects_query.to_sql + ')').as(table[:results].table_name) ).
        outer_join(table[:permission_requirements]).on(
          table[:permission_requirements][:required_on_type].eq(klass.name).and(
            table[:permission_requirements][:required_on_id].eq(table[:results][:id])
          )
        ).
        join(table[:roles]).on(
          table[:roles][:id].eq(table[:results][:role_id])
        ).
        join(table[:permissions_roles]).on(
          table[:permissions_roles][:role_id].eq(table[:roles][:id])
        ).
        join(table[:permissions]).on(
          table[:permissions][:id].eq(table[:permissions_roles][:permission_id])
        ).
        join(table[:permission_states_permissions]).on(
          table[:permission_states_permissions][:permission_id].eq(table[:permissions][:id])
        ).
        join(table[:permission_states]).on(
          table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
        ).
        where(
          table[:results][:id].not_eq(nil).and(
            table[:permission_requirements].primary_key.eq(nil).or(
              table[:permission_requirements][:permission_id].eq(table[:results][:permission_id])
            )
          ).and(
            table[:permissions][:applies_to].in(applies_to)
          )
        ).
        group(table[:results][:id])

    end

    def to_sql
      to_arel.to_sql
    end
  end
end
