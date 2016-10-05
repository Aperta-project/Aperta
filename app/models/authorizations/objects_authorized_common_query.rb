module Authorizations
  class ObjectsAuthorizedCommonQuery
    include QueryHelpers
    attr_reader :auth_config, :query, :klass, :assignments_table

    def initialize(auth_config:, klass:, assignments_table:)
      @auth_config = auth_config
      @klass = klass
      @assignments_table = assignments_table
    end

    def assigned_to_klass
      auth_config.assignment_to
    end

    def join_table
      assigned_to_klass.arel_table
    end

    def target_table
      klass.arel_table
    end

    # +permission_state_column+ should return the column that houses
    # a model's state.
    #
    # This is so permissions that are tied to states can add a
    # WHERE condition in the query for matching against the right states.
    #
    # Right now this is set up to work for Paper(s). If the system needs to
    # evolve to work with other kinds of models this is the entry point for
    # refactoring, replacing, or removing.
    def permission_state_column
      'publishing_state'
    end

    def to_arel
      assignments_table.project(
        klass.arel_table.primary_key.as('id'),
        assignments_table[:role_id].as('role_id'),
        assignments_table[:permission_id].as('permission_id')
      )
    end

    def to_sql
      to_arel.to_sql
    end

    def add_permission_state_check_to_query(query)
      local_permission_state_column = if klass.respond_to?(:delegate_state_to)
        delegate_permission_state_to_association = klass.delegate_state_to.to_s
        delegate_state_table = klass.reflections[delegate_permission_state_to_association].klass.arel_table
        delegate_state_table[permission_state_column]
      elsif klass.column_names.include?(permission_state_column.to_s) # e.g. Paper has its own publishing state column
        klass.arel_table[permission_state_column]
      end

      return query unless local_permission_state_column

      query.join(table[:permissions]).on(
        table[:permissions][:id].eq(assignments_table[:permission_id])
      )
      query.outer_join(table[:permission_states_permissions]).on(
        table[:permission_states_permissions][:permission_id].eq(assignments_table[:permission_id])
      )
      query.outer_join(table[:permission_states]).on(
        table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
      )

      # Check to see if we need to JOIN on the table that owns the
      # local_permission_state_column. This is necessary if a class is
      # delegating their state permission column to an association, but that
      # associaton has not been loaded, e.g. Task -> Paper#publishing_state
      if !query.join_sources.map(&:left).map(&:name).include?(local_permission_state_column.relation.name)
        query.join(local_permission_state_column.relation).on(
          local_permission_state_column.relation.primary_key.eq(
            klass.arel_table[
              klass.reflections[delegate_permission_state_to_association].foreign_key
            ]
          )
        )
      end

      query.where(
        table[:permission_states][:name].eq(local_permission_state_column).or(
          table[:permission_states][:name].eq(PermissionState::WILDCARD.to_s)
        )
      )

      # If the @klass uses STI then we need to add conditions which enforces
      # scope based on the permissions.applies_to column.
      if @klass.column_names.include?(@klass.inheritance_column)
        qs = [@klass].concat(@klass.descendants).reduce(nil) do |q, permissible_klass|
          eligible_ancestors = (permissible_klass.ancestors & permissible_klass.base_class.descendants) << permissible_klass.base_class
          condition = klass.arel_table[:type].eq(permissible_klass.name).and(
            table[:permissions][:applies_to].in(eligible_ancestors.map(&:name))
          )
          q ? q.or(condition) : condition
        end
        query.where(qs)
      else
        # no-op for non-STI klasses
      end

      query
    end
  end
end
