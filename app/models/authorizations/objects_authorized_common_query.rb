module Authorizations

  # ObjectsAuthorizedCommonQuery contains a bunch of common methods
  # useful fo building up other queries. It's a helper class.
  #
  # == Note
  #
  # We pulled this out has a separate class rather than as a base-class
  # or a module because we thought it would make it easier to reason about
  # the code later on if there was an explicit boundary.
  class ObjectsAuthorizedCommonQuery
    include QueryHelpers

    attr_reader :auth_config, :query, :klass, :assignments_table

    # == Constructor Arguments
    # * assignments_table: the Arel::Table reference representing the \
    #     assignments table to use for this query
    # * auth_config: the Authorization(s) path to JOIN against
    # * klass: the type/class that is being queried against
    def initialize(auth_config:, klass:, assignments_table:)
      @auth_config = auth_config
      @klass = klass
      @assignments_table = assignments_table
    end

    # Returns the class that the current Authorization instance is
    # assigned_to.
    def assigned_to_klass
      auth_config.assignment_to
    end

    # Returns the Arel::Table instance for the +assigned_to_klass+
    def join_table
      assigned_to_klass.arel_table
    end

    # Returns the Arel::Table instance for @klass
    def target_table
      klass.arel_table
    end

    # +permission_state_column+ returns the column that houses
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

    # Adds a WHERE clause condition to the query for the given column
    # if the provided set of value(s) is not nil. Otherwise, no-op.
    def add_column_condition(query:, column:, values:)
      return query if values.nil?
      query.where(column.in(values))
    end

    # Adds JOINs and WHERE clause conditions to the given query for
    # enforcing permission state checks. If the current @klass does not
    # have a column for its permission state and does not implement a
    # class-level +delegate_state_to+ method that returns the name of an
    # association to delegate the state check to, then this is a no-op
    # and the given query will not be modified in any way.
    def add_permission_state_check(query)
      # This checks to see if the current @klass delegates the permission
      # state checks. E.g. Task currently delegates permission state checks to
      # Paper.
      local_permission_state_column = if klass.respond_to?(:delegate_state_to)
        delegate_permission_state_to_association = klass.delegate_state_to.to_s
        delegate_state_table = klass.reflections[delegate_permission_state_to_association].klass.arel_table
        delegate_state_table[permission_state_column]
      elsif klass.column_names.include?(permission_state_column.to_s) # e.g. Paper has its own publishing state column
        # E.g. Paper.arel_table['publishing_state']
        klass.arel_table[permission_state_column]
      end

      # if there is no permission state column to use then do nothing
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

      add_wildcard_conditions_for_permission_state_check(
        query,
        local_permission_state_column
      )
      add_sti_conditions_for_permission_state_check(query)

      query
    end

    private

    # If the @klass uses STI then we need to add conditions which enforces
    # scope based on the permissions.applies_to column.
    #
    # Given the following hierarchy:
    #
    #     D < C < B < A
    #
    # A is the base class. It is the least specialized. D on the other hand
    # is the most specialized. This means that permissions on A trickle
    # down to include B, C, and D, but the reverse is not true.
    #
    # Here's an example...
    #
    # We want to generate the correct set of conditions so we need to add
    # WHERE clause conditions for permissions.applies_to at every level of
    # the STI inheritance hierarchy.
    #
    # If a record is an A then we need a permission that applies_to A.
    # Permissions that apply to B, C, and D are do not qualify
    # because they are more specific.
    #
    # If a record is a B then we need a permission that applies
    # to A or B.
    #
    # If a record is a C then we need a permission that applies
    # to A, B, or C.
    #
    # If a record is a D then we need a permission that applies
    # to A, B, C, or D.
    #
    # This will result in potentially a lot of SQL, but the database is pretty
    # fast at applying these conditions.
    def add_sti_conditions_for_permission_state_check(query)
      if @klass.column_names.include?(@klass.inheritance_column)
        # qs is short for queries, q in the block is short for query.
        # These names were chosen since we're passing in a +query+ variable.
        # If you have better names, let's use yours. :)
        qs = [@klass].concat(@klass.descendants).reduce(nil) do |q, permissible_klass|

          # Given the following hierarchy:
          #    D < C < B < A
          #
          # If permissible_klass is C then +klasses+ will become
          #   [A, B]
          #
          klasses = (permissible_klass.ancestors & permissible_klass.base_class.descendants)

          # Now add back in our current permissible_klass C. +klasses+ is now:
          #  [A, B, C]
          klasses << permissible_klass.base_class

          # Here we add the condition to allow any record whose
          # permission.applies_to is for A, B, or C
          condition = klass.arel_table[:type].eq(permissible_klass.name).and(
            table[:permissions][:applies_to].in(klasses.map(&:name))
          )

          # Based on how Arel works we need to chain conditions rather than
          # apply them all to the query object.
          q ? q.or(condition) : condition
        end
        query.where(qs)
      else
        # no-op for non-STI klasses
      end
    end

    # Allow for exact permission state matches OR any wildcard matches
    def add_wildcard_conditions_for_permission_state_check(query, state_column)
      query.where(
        table[:permission_states][:name].eq(state_column).or(
          table[:permission_states][:name].eq(PermissionState::WILDCARD.to_s)
        )
      )
    end
  end
end
