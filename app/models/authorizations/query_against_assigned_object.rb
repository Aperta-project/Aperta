# rubocop:disable all
module Authorizations
  # QueryAgainstAssignedObject builds the query for finding authorized
  # objects.
  class QueryAgainstAssignedObject
    WILDCARD_STATE = Authorizations::Query::WILDCARD_STATE

    attr_reader :assignments, :permissible_states

    # == Constructor Arguments
    # * klass - the class that we're looking for authorization against. This \
    #           is expected to be the model class for the 'target' argument.
    # * target - the target object, scope (ActiveRecord::Relation), or class \
    #            that we are querying against.
    # * assignments - a collection of assignments for the user that provide
    #            access to objects that we're looking for (e.g. see klass)
    # * permissible_states - a collection of states (as strings) that should
    #            be queried against
    # * state_column - the name of the state column on +klass+ to check
    #            +permissible_states+ against
    def initialize(klass:, target:, assignments:, permissible_states:, state_column:, state_join: nil)
      @klass = klass
      @target = target
      @assignments = assignments
      @assigned_to_ids = assignments.map(&:assigned_to_id)
      @permissible_states = permissible_states.dup
      @state_column = state_column.to_s
      @state_join = state_join
    end

    def query
      if @target.is_a?(ActiveRecord::Base) # e.g. <Foo#ab3ad3 id: 1>
        short_circuit_query_for_specific_model
      elsif @target.is_a?(ActiveRecord::Relation) # e.g. Foo.all, Foo.where(...)
        query_against_active_record_relation
      elsif @target <= ActiveRecord::Base # e.g. Foo
        query_against_assigned_klass
      else
        raise(
          NotImplementedError,
          "Not sure how to query against #{@target.inspect}"
        )
      end
    end

    private

    def short_circuit_query_for_specific_model
      return [] unless @assigned_to_ids.include?(@target.id)

      has_state = if @state_join
        permissible_states.include?(@target.send(@state_join).send(@state_column))
      else
        has_state_column = @target.class.column_names.include?(@state_column)
        has_state_column && permissible_states.include?(@target.send(@state_column))
      end
      if permissible_states.include?(WILDCARD_STATE)
        [@target]
      elsif has_state_column
        has_state ? [@target] : []
      else
        [@target]
      end
    end

    def query_against_assigned_klass
      query = @klass.where(id: @assigned_to_ids)
      query = add_permissible_state_conditions_to_query(query)
      query
    end

    def query_against_active_record_relation
      query = ActiveRecord::Relation.create(
        @klass,
        @klass.arel_table,
        @target.values
      ).where(id: @assigned_to_ids)
      query = add_permissible_state_conditions_to_query(query)
      query
    end

    # If the klass we're querying against doesn't have the @state_column
    # then this won't add any permission/state conditions to the query.
    def add_permissible_state_conditions_to_query(query)
      if !permissible_states.include?(WILDCARD_STATE)
        if @state_join
          return query.joins(@state_join).where(@state_join.to_s.pluralize => { @state_column => permissible_states })
        elsif @klass.column_names.include?(@state_column)
          return query.where(@state_column => permissible_states)
        end
      end
      query
    end
  end
end
# rubocop:enable all
