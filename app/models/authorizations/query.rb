# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

module Authorizations
  class Error < ::StandardError; end
  class QueryError < Error; end
  class MissingAssociationForAuthConfiguration < Error; end

  # Query represents the entry-point into the Authorizations sub-system. It's
  # where you start if you want to find accessible objects or check access
  # of an existing object.
  #
  # == Example - Find all papers that a user can view
  #
  #     Authorizations::Query.new(
  #       permission: :view,
  #       target: Paper.all,
  #       user: User.find(14),
  #       participations_only: false
  #     ).all
  #
  # == Example - Find all papers that a user can view and is participating in
  #
  #     Authorizations::Query.new(
  #       permission: :view,
  #       target: Paper.all,
  #       user: User.find(14),
  #       participations_only: true
  #     ).all
  #
  # == More Examples
  #
  # For more examples of what's possible see the specs in spec/authorizations/
  # directory.
  #
  # == More information on participations_only
  #
  # participations_only is used to check if any of the roles a user is
  # assigned to should be considered an active participant as opposed to
  # somebody with access. This is useful for displaying relevant papers
  # on a user's dashboard.
  #
  # Some users, like Journal-level Staff Admins, have access to a lot of papers
  # in the system, but they aren't participating in many of them. Maybe even
  # none of them. When trying to determine what to show on the dashboard it
  # may be relevant to display papers they are actively participating in.
  #
  # == Notes
  #
  # The Authorizations::UserHelper module provides convenience methods
  # that wrap this object. Check those before using this object directly.
  #
  # rubocop:disable ClassLength
  class Query
    include QueryHelpers

    attr_reader :permission, :klass, :user

    # == Constructor Arguments
    # * permission: the permission action to check against, e.g. :view
    # * target: the object, class, or ActiveRecord::Relation that is being \
    #    being authorized
    # * user: the user who the query will be check for authorization against
    # * participations_only: a boolean specifying if only targets a user \
    #     participates in should be returned. If not specified, it depends on \
    #     the target passed in. For Class or ActiveRecord::Relation, it is \
    #     true, for Array or ActiveRecord::Base, it is false.
    def initialize(permission:, target:, user:, participations_only: :default)
      @permission = permission.to_sym
      @user = user
      @target = target
      @participations_only = participations_only

      initialize_for_target
    end

    # Returns an Authorizations::ResultSet instance containing the
    # results of the query.
    def all
      return ResultSet.new unless @target

      # Always force participation checks to go thru R&P. Why?
      # Because a site admin can access everything but should not be inundated
      # with every single paper on their dashboard.
      if user.site_admin? && !@participations_only
        load_all_objects
      else
        load_authorized_objects
      end
    end

    private

    def initialize_for_target
      if @target.is_a?(Class)
        initialize_for_class
      elsif @target.is_a?(ActiveRecord::Base)
        initialize_for_activerecord_instance
      elsif @target.is_a?(ActiveRecord::Relation)
        initialize_for_activerecord_relation
      elsif @target.is_a?(Array)
        initialize_for_array_of_activerecord_instances
      end
    end

    def initialize_for_class
      @klass = @target
      @participations_only = true if @participations_only == :default

      # If @target is provided as a class then we need to re-set target
      # to an ActiveRecord::Relation scoped to all instances.
      @target = @target.all
    end

    def initialize_for_activerecord_instance
      @klass = @target.class
      @participations_only = false if @participations_only == :default

      # If @target is provided as an ActiveRecord instance then we need to
      # re-set target to an ActiveRecord::Relation scoped down to that
      # instance.
      @target = @klass.where(id: @target.id)
    end

    def initialize_for_activerecord_relation
      @klass = @target.model
      @participations_only = true if @participations_only == :default
    end

    def initialize_for_array_of_activerecord_instances
      @klass = @target.first.class
      @participations_only = false if @participations_only == :default
    end

    # This walks thru the Authorizations::Configuration and returns all
    # Authorizations::Authorization instances where the authorized type
    # the same klass of @klass or a descendant of @klass.
    #
    # Note: This will also add in an Authorization for self references.
    # E.g. for an assignment to Task to authorize Task. A self
    # assignment/authorization an implicit authorization path.
    def auth_configs
      @auth_configs ||= begin
        Authorizations.configuration.authorizations.select do |ac|
          # if what we're authorizing is the same class or an ancestor of @klass
          ac.authorizes >= @klass
        end
      end.concat([Authorizations::Authorization.new(
        assignment_to: @klass,
        authorizes: @klass,
        via: :self
      )])
    end

    # Returns an array of types/classes that are eligible for this query.
    # For example, Task has a lot of subclasses. If we are searching for all
    # authorized tasks for a user (e.g. @target=Task.all) then we need to
    # to check the permissions.applies_to column for Task and any of its
    # subclasses.
    #
    # This specifically is meant to correspond with what permissions.applies_to
    # column values are valid based on the @klass of this query.
    def eligible_applies_to
      eligible_ancestors = @klass.ancestors & @klass.base_class.descendants
      [
        @klass.descendants,
        @klass,
        eligible_ancestors,
        @klass.base_class
      ].flatten.map(&:name).uniq
    end

    # This method, intended to be used in the case of Site Admins(s) or other
    # System-level roles that have access to everything in the system, will
    # return a ResultSet object including the results of whatever the
    # original @target was requesting.
    #
    # Note: This method should not be called if @participations_only is true
    def load_all_objects
      result_set = ResultSet.new
      return result_set if @participations_only

      permissions = Permission.where(applies_to: eligible_applies_to)
      permissions_hash = permissions.each_with_object({}) do |permission, hsh|
        action = permission.action.to_sym
        hsh[action] = { states: [PermissionState::WILDCARD] }
      end

      if @target.is_a?(Class)
        result_set.add_objects(@target.all, with_permissions: permissions_hash)
      elsif @target.is_a?(ActiveRecord::Base)
        result_set.add_objects([@target], with_permissions: permissions_hash)
      elsif @target.is_a?(ActiveRecord::Relation)
        result_set.add_objects(@target.all, with_permissions: permissions_hash)
      end
    end

    # Returns a ResultSet of all authorized objects returned by this query.
    def load_authorized_objects
      # Short-circuit out of here if there are no configured authorization
      # pathways for this query
      return ResultSet.new if auth_configs.empty?

      hydrate_objects_from_query(
        results_with_permissions_query
      ).to_result_set
    end

    # Takes a query object and hydrates it returning a HydratesObject
    # instance.
    def hydrate_objects_from_query(query_to_hydrate)
      hydrate_objects_query = HydrateObjectsQuery.new(
        klass: klass,
        objects_with_permissions_query: query_to_hydrate,
        target: @target
      )

      HydrateObjects.new(
        query: hydrate_objects_query,
        klass: @klass,
        target: @target
      )
    end

    # Returns a PermissibleAssignmentsQuery instance responsible for finding
    # Assignment(s) whose roles have the requested @permission on the type
    # of @klass that we're querying against. These are all of the assignments
    # that could give the user permission/access to an object.
    def permissible_assignments_query
      PermissibleAssignmentsQuery.new(
        user: @user,
        permission: @permission,
        klass: @klass,
        applies_to: eligible_applies_to,
        auth_configs: auth_configs,
        participations_only: @participations_only
      )
    end

    # Returns a ObjectsViaAuthorizationsQuery instance responsible for
    # finding all objects that pertain to query through the configured
    # authorization paths. This will limit the search thru each of the
    # permissible_assignments found in the permissible_assignments_query.
    def objects_via_authorizations_query
      ObjectsViaAuthorizationsQuery.new(
        klass: @klass,
        target: @target,
        auth_configs: auth_configs,
        assignments_table: table[:permissible_assignments]
      )
    end

    # Returns a ObjectsPermissibleByRequiredPermissionsQuery instance
    # responsible for filtering the results of
    # objects_found_via_authorizations_query by any additional
    # permission_requirements.
    def results_with_permissions_query
      # We're going to use the permissible_assignments_query above as a
      # sub-query so let's wrap it in an alias/reference
      permissible_assignments_as_table = reference_query_as_table(
        permissible_assignments_query,
        table[:permissible_assignments].name
      )

      ObjectsPermissibleByRequiredPermissionsQuery.new(
        klass: @klass,
        assignments_table: permissible_assignments_as_table,
        objects_query: objects_via_authorizations_query,
        applies_to: eligible_applies_to
      )
    end
  end
  # rubocop:enable ClassLength
end
