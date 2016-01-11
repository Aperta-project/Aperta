# rubocop:disable all
module Authorizations
  class Query
    WILDCARD_STATE = '*'

    attr_reader :permission, :klass, :user

    def initialize(permission:, target:, user:)
      @permission = permission.to_sym
      @user = user
      @target = target
      @specific_ids = nil
      @include_only_participations = false

      # we're looking for everything, e.g. Task got passed in
      if target.is_a?(Class)
        @klass = target
        @include_only_participations = true

      # we're looking for a specific object, e.g. Task.first got passed in
      elsif target.is_a?(ActiveRecord::Base)
        @klass = target.class
        @specific_ids = [@target.id]

      # we're looking for a set of objects with a pre-existing query, e.g. Task.where(name: "Bar") got passed in
      elsif target.is_a?(ActiveRecord::Relation)
        @klass = target.model
        @include_only_participations = true

      # we're looking for a specific of objects e.g. [Task.first, Task.last] got passed in
      elsif target.is_a?(Array)
        @klass = target.first.class
        @specific_ids = @target.map(&:id)
      end
    end

    def all
      load_authorized_objects
    end

    private

    def allowed?(object, states)
      states.include?(WILDCARD_STATE) || !object.respond_to?(:publishing_state) || states.member?(object.send(:publishing_state))
    end

    def load_authorized_objects
      # Find all assignments for the current user states eligible based on the requested permission and class
      perm_q = { 'permissions.applies_to' => @klass.base_class.name }
      assignments = user.assignments.includes(permissions: :states).where(perm_q)

      # If @include_only_participations is true then we want to use specific fields
      # on Role to determine if we should consider these assignments. The purpose of this
      # is so users assigned to a paper with a role like Author (or Reviewer, etc) get papers
      # through assignments in their default list of papers (e.g. what they see on the dashboard).
      # But we don't want that for roles (e.g. Internal Editor assigned to a Journal).
      if @include_only_participations
        role_accessibility_method = "participates_in_#{@klass.table_name}"
        if Role.column_names.include?(role_accessibility_method)
          assignments = assignments.where(:roles => { role_accessibility_method => true })
        end
      end

      # Load all assignments the user has a permissible assignment for
      permissible_assignments = assignments.where('permissions.action' => @permission)

      # Load all assignments (including permissions and permission states)
      # based on the permissible assignments, but DO NOT limit it to the
      # permissible action. We want to know all permissions this user has
      # for the assignment.
      permissions_by_assignment_id = assignments.where('assignments.id' => assignments.map(&:id)).reduce({}) do |h, assignment|
        h[assignment.id] = assignment.permissions
        h
      end

      # Group by type so we can reduce queries later. 1 query for every combination of: kind of thing we're assigned to AND set of permissions.
      permissible_assignments_grouped = Hash.new{ |h,k| h[k] = [] }

      permissible_assignments.each do |assignment|
        permissions = assignment.permissions
        permissible_actions = permissions.flat_map(&:action).map(&:to_sym)
        permissible_state_names = permissions.flat_map(&:states).flat_map(&:name)
        all_permissions = permissions_by_assignment_id[assignment.id].reduce({}) do |h, permission|
          h[permission.action.to_sym] = { states: permission.states.map(&:name) }
          h
        end

        if permissible_actions.include?(@permission)
          group_by_key = {
            type: assignment.assigned_to_type,
            permissible_states: permissible_state_names,
            all_permissions: all_permissions
          }
          permissible_assignments_grouped[group_by_key] << assignment
        else
          # no-op: this assignment doesn't have a permission that allows authorization
        end
      end

      # Create a place to store the authorized objects
      result_set = ResultSet.new

      # Loop over the things we're assigned to and load them all up
      permissible_assignments_grouped.each_pair do |hsh, assignments|
        assigned_to_type = hsh[:type]
        permissible_states = hsh[:permissible_states]
        all_permissions = hsh[:all_permissions]

        assigned_to_klass = assigned_to_type.constantize
        authorized_objects = []

        # This is to make sure that if no permission states were hooked up
        # that we accept any state. It's more a fallback.
        permissible_states = ['*'] if permissible_states.empty?

        # determine how this kind of thing relates to what we're interested in
        if assigned_to_klass <= @klass
          authorized_objects = QueryAgainstAssignedObject.new(
            klass: @klass,
            target: @target,
            assignments: assignments,
            permissible_states: permissible_states
          ).query
          result_set.add_objects(authorized_objects, with_permissions: all_permissions)
        else
          # Determine how the Assignment#thing relates to object we're checking
          # permissions on. This can be pulled out later into a configurable property,
          # but for now just determined based on the reflection type that matches.
          Authorizations.configuration.authorizations
            .select { |auth|
              auth.authorizes >= @klass && # if what we're authorizing is the same class or an ancestor of @klass
              auth.assignment_to >= assigned_to_klass # if what you're assigned to is the same class
            }
            .each do |auth|

            authorized_objects = QueryAgainstAuthorization.new(
              authorization: auth,
              klass: @klass,
              target: @target,
              assigned_to_klass: assigned_to_klass,
              assignments: assignments,
              permissible_states: permissible_states
            ).query
            result_set.add_objects(authorized_objects, with_permissions: all_permissions)
          end
        end
      end

      result_set
    end

    class ResultSet
      def initialize
        @object_permission_map = Hash.new{ |h,k| h[k] = {} }
      end

      def add_objects(objects, with_permissions:)
        objects.each do |object|
          @object_permission_map[object].merge!(with_permissions)
        end
      end

      def objects
        @object_permission_map.keys
      end

      delegate :each, :map, :length, to: :@object_permission_map

      def to_h
        results = []
        each do |object, permissions|
          item = {
            object: { id: object.id, type: object.class.sti_name },
            permissions: permissions
          }

          results.push item
        end
        results
      end
    end
  end

  class QueryAgainstAuthorization
    attr_reader :assignments, :assigned_to_klass, :authorization, :permissible_states

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

      updated_where_values = @target.where_values.map do |value|
        if value.is_a?(Arel::Nodes::Node) && value.respond_to?(:right) && value.right.is_a?(Arel::Nodes::BindParam)
          # no-op
        else
          value = value.to_sql if value.respond_to?(:to_sql)
          value.gsub(/\b([^\s]+)\s*(\=|\!\=|<>)/) do |field_name|
            field_name_includes_table_reference = field_name.include?('.')
            unless field_name_includes_table_reference
              "#{reflection.table_name}.#{field_name}"
            else
              field_name
            end
          end
        end
      end.compact

      if updated_where_values.any?
        query = query.where(updated_where_values)
      else
        query = query.merge @target
      end

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
      query = @klass.where(id: @assigned_to_ids)
      query = query.merge(@target)
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
