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

      results = filter_down_permissible_items(query.flatten.uniq)
      results
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

    # Filters down the given list of items based on permission_requirements.
    # If there are no permission_requirements then the item is considered
    # permissible otherwise an item is only included in the returned collection
    # if the user has a matching permission based on their assignments.
    #
    # Note: This is done in Ruby because we have all the data we need already
    # and because it is difficult to determine if an entire set of joined
    # permission_requirements is empty or has at least one value.
    def filter_down_permissible_items(items)
      user_permission_ids = assignments.flat_map(&:permissions).map(&:id)

      items.select do |item|
        if item.respond_to?(:permission_requirements)
          item_permission_ids = \
            item.permission_requirements.map(&:permission_id)
          intersect_of_permissions = item_permission_ids & user_permission_ids
          item.permission_requirements.empty? || intersect_of_permissions.any?
        else
          item
        end
      end
    end

    def query_against_specific_model
      query = @target.class.where(id: @target.id)
      if @target.respond_to?(:required_permissions)
        query = query.includes(:permission_requirements)
      end
      query
    end

    def query_against_active_record_relation
      query = base_query_for_active_record_relations

      if @target.model.reflections['required_permissions']
        query = query.includes(:permission_requirements)
      end

      if klass_supports_single_table_inheritance?(@target.model)
        applies_to_including_descendants = assignments
          .flat_map(&:permissions)
          .flat_map(&:applies_to)
          .flat_map do |str|
            [str, str.constantize.descendants.map(&:name)]
        end
        query = query.where(
          type: applies_to_including_descendants.flatten
        )
      end

      query
    end

    def klass_supports_single_table_inheritance?(klass)
      @target.model.base_class != @target.model.base_class ||
        klass.descendants.any?
    end
  end
end
# rubocop:enable all
