# rubocop:disable all
module Authorizations
  class QueryAgainstAssignedObject
    attr_reader :assignments, :permissible_states

    def initialize(klass:, target:, assignments:, permissible_states:)
      @klass = klass
      @target = target
      @assignments = assignments
      @assigned_to_ids = assignments.map(&:assigned_to_id)
      @permissible_states = permissible_states.dup
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

      has_state_column = @target.class.column_names.include?('state')
      has_state = has_state_column && permissible_states.include?(@target.state)

      if permissible_states.include?('*')
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

    def add_permissible_state_conditions_to_query(query)
      if !permissible_states.include?('*') && @klass.column_names.include?('state')
        query.where(state: permissible_states)
      else
        query
      end
    end
  end
end
# rubocop:enable all
