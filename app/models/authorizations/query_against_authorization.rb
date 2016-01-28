# rubocop:disable all
module Authorizations
  # QueryAgainstAuthorization builds the query for finding authorized
  # objects against an Authorizations::Authorization object.
  class QueryAgainstAuthorization
    WILDCARD_STATE = Authorizations::Query::WILDCARD_STATE

    attr_reader :assignments, :assigned_to_klass, :authorization, :permissible_states

    # == Constructor Arguments
    # * authorization - the Authorizations::Authorization object we should
    #           query against
    # * klass - the class that we're looking for authorization against. This \
    #           is expected to be the model class for the 'target' argument.
    # * target - the target object, scope (ActiveRecord::Relation), or class \
    #            that we are querying against.
    # * assignments - a collection of assignments for the user that provide
    #            access to objects that we're looking for (e.g. see klass)
    # * assigned_to_klass - the class the user is assigned. This is often \
    #            the same as +authorization.assignment_to+ but may differ if
    #            we were assigned to a subclass so it's passed in separately
    # * permissible_states - a collection of states (as strings) that should
    #            be queried against
    # * state_column - the name of the state column on +klass+ to check
    #            +permissible_states+ against
    def initialize(authorization:, klass:, target:, assignments:, assigned_to_klass:, permissible_states:, state_column:)
      @authorization = authorization
      @klass = klass
      @target = target
      @assignments = assignments
      @assigned_to_ids = assignments.map(&:assigned_to_id)
      @assigned_to_klass = assigned_to_klass
      @permissible_states = permissible_states
      @state_column = state_column.to_s
    end

    def query
      if @target.is_a?(ActiveRecord::Base)
        query = query_against_specific_model
      elsif @target.is_a?(ActiveRecord::Relation)
        query = query_against_active_record_relation
      end
      query = add_permissible_state_conditions_to_query(query)
      query.flatten.uniq
    end


    private

    # If the klass we're querying against doesn't have the @state_column
    # then this won't add any permission/state conditions to the query.
    def add_permissible_state_conditions_to_query(query)
      if !permissible_states.include?(WILDCARD_STATE) && @klass.column_names.include?(@state_column)
        query = query.where(@klass.table_name => { @state_column => permissible_states } )
      else
        query
      end
    end

    def base_query_for_active_record_relations
      inverse_association = assigned_to_klass.reflections[authorization.via.to_s].inverse_of

      if !inverse_association
        raise CannotFindInverseAssociation, <<-MSG.strip_heredoc
          From looking at the association #{authorization.via.inspect} on
          #{assigned_to_klass} its inverse cannot be determined.

          You may need to specify an an :inverse_of option on that association
          as well as ensure that the inverse association on #{@klass} does
          indeed exist.

          So sorry to be difficult here, but this information will really help
          us – the authorization sub-system minions – return the right
          records.

          Yours truly,

          The Authorization Sub-System Minions
        MSG
      end
      inverse_association_name = inverse_association.name.to_sym

      @target.joins(inverse_association_name)
        .includes(inverse_association_name)
        .where(
          inverse_association.table_name => { id: @assigned_to_ids }
        )
    end

    def query_against_specific_model
      query = @target.class.where(id: @target.id)

      if @target.class.column_names.include?('required_permission_id')
        field = "#{@target.class.table_name}.required_permission_id"
        assigned_permission_ids = assignments.flat_map(&:permissions).map(&:id)
        query = query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assigned_permission_ids
        )
      end
      query
    end

    def query_against_active_record_relation
      query = base_query_for_active_record_relations
      if @target.model.column_names.include?('required_permission_id')
        field = "#{@target.table.name}.required_permission_id"
        query = query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assignments.flat_map(&:permissions).map(&:id)
        )
      end
      query
    end
  end
end
# rubocop:enable all
