# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

# rubocop:disable all
module Authorizations
  class Error < ::StandardError ; end
  class QueryError < Error ; end
  class CannotFindInverseAssociation < QueryError ; end

  # Query represents the quer(y|ies) for finding the authorized objects from
  # the database based on how the authorizations sub-system is configured,
  # what the user is assigned to, what roles the person has, and what
  # permissions they have thru those roles.
  class Query
    # WILDCARD_STATE represents the notion that any state is valid.
    WILDCARD_STATE = PermissionState::WILDCARD

    attr_reader :permission, :klass, :user

    # == Constructor Arguments
    # * permission - is the permission you are checking for authorization \
    #                against
    # * target - is the object, class, or ActiveRecord::Relation that is being \
    #            being authorized
    # * user - is the user who the query will be check for authorization against
    # * participations_only - a boolean specifying if only targets a user
    #                         participates in should be returned. If not
    #                         specified, it depends on the target passed in. For
    #                         Class or ActiveRecord::Relation, it is true, for
    #                         Array or ActiveRecord::Base, it is false.
    def initialize(permission:, target:, user:, participations_only: :default)
      @permission = permission.to_sym
      @user = user
      @target = target
      @participations_only = participations_only

      # we're looking for everything, e.g. Task got passed in
      if target.is_a?(Class)
        @klass = target
        @target = target.all
        @participations_only = true if @participations_only == :default

      # we're looking for a specific object, e.g. Task.first got passed in
      elsif target.is_a?(ActiveRecord::Base)
        @klass = target.class
        @target = @klass.where(id: target.id)
        @participations_only = false if @participations_only == :default

      # we're looking for a set of objects with a pre-existing query, e.g. Task.where(name: "Bar") got passed in
      elsif target.is_a?(ActiveRecord::Relation)
        @klass = target.model
        @participations_only = true if @participations_only == :default

      # we're looking for a specific of objects e.g. [Task.first, Task.last] got passed in
      elsif target.is_a?(Array)
        @klass = target.first.class
        @participations_only = false if @participations_only == :default
      end
    end

    def all
      if user.site_admin
        # TODO: Remove this when site_admin is no more
        load_all_objects
      else
        load_authorized_objects
      end
    end

    private

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
      :publishing_state
    end

    # +permission_state_join+ allows for a model to delegate their state
    # by implementing a `delegate_state_to` method on the class that
    # returns the name of the association to delegate to as a symbol.
    #
    # For example, having the following method in a model will delegate permission state to Paper:
    #  def self.delegate_state_to
    #    :paper
    #  end
    def permission_state_join
      @klass.try(:delegate_state_to)
    end

    def allowed?(object, states)
      states.include?(WILDCARD_STATE) ||
        !object.respond_to?(permission_state_column) ||
        states.member?(object.send(permission_state_column))
    end

    def load_all_objects
      result_set = ResultSet.new
      permission_names = Permission.where(applies_to: eligible_applies_to).pluck(:action)
      permission_hsh = {}
      permission_names.each do |name|
        permission_hsh[name.to_sym] = { states: ['*'] }
      end
      if @target.is_a?(Class)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Base)
        result_set.add_objects([@target], with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Relation)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      end
      return result_set
    end

    # Returns the eligible values for a permission applies_to given the
    # @klass being queried. This searches the class, any of its descendants,
    # as well as any ancestors in the lineage from the @klass to its base-class.
    def eligible_applies_to
      eligible_ancestors = @klass.ancestors & @klass.base_class.descendants
      [
        @klass.descendants,
        @klass,
        eligible_ancestors,
        @klass.base_class
      ].flatten.map(&:name).uniq
    end

    def load_authorized_objects
      perm_q = { 'permissions.applies_to' => eligible_applies_to }
      assignments = user.assignments.includes(permissions: :states).where(perm_q)

      # If @participations_only is true then we want to use specific fields
      # on Role to determine if we should consider these assignments. The purpose of this
      # is so users assigned to a paper with a role like Author (or Reviewer, etc) get papers
      # through assignments in their default list of papers (e.g. what they see on the dashboard).
      # But we don't want that for roles (e.g. Internal Editor assigned to a Journal).
      if @participations_only
        role_accessibility_method = "participates_in_#{@klass.table_name}"
        if Role.column_names.include?(role_accessibility_method)
          assignments = assignments.where(:roles => { role_accessibility_method => true })
        end
      end

      # Load all assignments the user has a permissible assignment for
      if @permission == :*
        permissible_assignments = assignments.all
      else
        permissible_assignments = assignments.where('permissions.action' => @permission)
      end

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
          h[permission.action.to_sym] = { states: permission.states.map(&:name).sort }
          h
        end

        if permissible_actions.include?(@permission) || @permission == :*
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
        permissible_states = [WILDCARD_STATE] if permissible_states.empty?

        # determine how this kind of thing relates to what we're interested in
        if assigned_to_klass <=> @klass
          authorized_objects = QueryAgainstAssignedObject.new(
            klass: @klass,
            target: @target,
            assignments: assignments,
            state_join: permission_state_join,
            permissible_states: permissible_states,
            state_column: permission_state_column
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
              permissible_states: permissible_states,
              state_join: permission_state_join,
              state_column: permission_state_column
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
          object_hsh = (@object_permission_map[object] ||= {})

          with_permissions.each_pair do |action, hsh|
            action_hsh = object_hsh[action] ||= { states: [] }

            # permission states may come thru multiple role assignments
            # so we want to merge them together rather than overwrite
            # what may have previously come thru
            action_hsh[:states].concat(hsh[:states]).uniq!
          end
        end
      end

      def objects
        @object_permission_map.keys
      end

      delegate :each, :map, :length, to: :@object_permission_map

      def as_json
        serializable.as_json
      end

      def serializable
        results = []
        each do |object, permissions|
          item = PermissionResult.new(
            object: { id: object.id, type: object.class.sti_name },
            permissions: permissions,
            id: "#{Emberize.class_name(object.class)}+#{object.id}"
          )

          results.push item
        end
        results
      end
    end
  end
end

class PermissionResult
  attr_accessor :object, :permissions, :id
  include ActiveModel::SerializerSupport

  def initialize(object:, permissions:, id:)
    @object = object
    @permissions = permissions
    @id = id
  end
end
# rubocop:enable all
