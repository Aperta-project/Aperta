# rubocop:disable all
module Authorizations
  # QueryAgainstAuthorization builds the query for finding authorized
  # objects against an Authorizations::Authorization object.
  class QueryAgainstAuthorization
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
    def initialize(authorization:, klass:, target:, assignments:, assigned_to_klass:, permissible_states:)
      @authorization = authorization
      @klass = klass
      @target = target
      @assignments = assignments
      @assigned_to_ids = assignments.map(&:assigned_to_id)
      @assigned_to_klass = assigned_to_klass
      @permissible_states = permissible_states
    end

    def base_query
      assigned_to_klass
        .joins(authorization.via.to_sym).includes(authorization.via.to_sym)
        .where(id: assignments.map(&:assigned_to_id))
    end

    def query_against_specific_model
      query = base_query.where(@klass.table_name => { id: @target.id } )

      if @target.class.column_names.include?('required_permission_id')
        field = "#{@target.class.table_name}.required_permission_id"
        assigned_permission_ids = assignments.flat_map(&:permissions).map(&:id)
        query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assigned_permission_ids
        )
      end
      query
    end

    def query
      if @target.is_a?(ActiveRecord::Base)
        query = query_against_specific_model
      elsif @target.is_a?(ActiveRecord::Relation)
        query = query_against_active_record_relation
      end

      if !permissible_states.include?('*') && @klass.column_names.include?("publishing_state")
        query = query.where(@klass.table_name => { publishing_state: permissible_states } )
      end

      authorized_objects = if @authorization.via != :self
        query.flat_map(&authorization.via).uniq
      else
        query.uniq
      end
    end

    private

    def query_against_active_record_relation
      query = base_query
      reflection = authorization.assignment_to.reflections[authorization.via.to_s]
      new_arel_values = update_arel_values(query.values)
      query = ActiveRecord::Relation.new(
        query.model,
        query.model.arel_table,
        new_arel_values
      )

      if @target.model.column_names.include?('required_permission_id')
        field = "#{@target.table.name}.required_permission_id"
        query = query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assignments.flat_map(&:permissions).map(&:id)
        )
      end
      query
    end

    def update_arel_values(arel_values)
      new_arel_values = arel_values.dup
      @target.values.each_pair do |key, values|
        next unless values

        if key == :joins
          update_arel_joins_values(new_arel_values, values)
        elsif new_arel_values[key]
          new_arel_values[key] += values
        else
          new_arel_values[key] = values
        end
      end
      new_arel_values
    end

    def update_arel_joins_values(arel_values, joins_values)
      arel_values[:joins] ||= []
      joins_values.each do |join_value|
        if arel_values[:joins].include?(join_value)
          # skip it we already have it
        elsif base_query.model.reflections.keys.include?(join_value.to_s)
          arel_values[:joins] << join_value.to_sym
        elsif join_value.is_a?(Arel::Node)
          arel_values[:joins] << join_value.left.name.to_sym
        else
          join_thru_model = base_query.model.reflections[@authorization.via.to_s]
          join_thru = join_thru_model.name
          arel_values[:joins] << { join_thru_model.name => join_value }
        end
      end
      arel_values
    end

  end


end
# rubocop:enable all
