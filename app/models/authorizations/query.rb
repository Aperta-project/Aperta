# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

# rubocop:disable all
module Authorizations
  class Error < ::StandardError ; end
  class QueryError < Error ; end
  class MissingAssociationForAuthConfiguration < Error ; end

  # Query represents the quer(y|ies) for finding the authorized objects from
  # the database based on how the authorizations sub-system is configured,
  # what the user is assigned to, what roles the person has, and what
  # permissions they have thru those roles.
  class Query
    include QueryHelpers
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
      return ResultSet.new unless @target

      if user.site_admin? && !@participations_only
        load_all_objects
      else
        load_authorized_objects
      end
    end

    private


    # +load_all_objects+ is a way to bypass R&P queries. It is intended to be
    # used in the case of Site Admins(s) or other System-level roles that
    # have access to everything in the system.
    #
    # Note: If :participations_only is true then this will never return any
    # records. This is because System accounts should _never_ be considered
    # participants.
    def load_all_objects
      result_set = ResultSet.new

      permission_names = Permission.where(applies_to: eligible_applies_to).pluck(:action)
      permission_hsh = {}
      permission_names.each do |name|
        permission_hsh[name.to_sym] = { states: [PermissionState::WILDCARD] }
      end

      if @target.is_a?(Class)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Base)
        result_set.add_objects([@target], with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Relation)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      end

      result_set
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


    # This walks the authorization configuration file and creates a path from
    # a authorized parent to all authorized children
    # For example: paper authorizes tasks.
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


    def load_authorized_objects
      return ResultSet.new if auth_configs.empty?

      # Find all of the assignments that the user has where the role they are
      # assigned to has permission on the kind of thing (klass) in question.
      assignments_arel = PermissibleAssignmentsQuery.new(
        user: @user,
        permission: @permission,
        klass: @klass,
        applies_to: eligible_applies_to,
        auth_configs: auth_configs,
        participations_only: @participations_only
      ).to_arel

      # We're going to use the assignments_query above as a sub-query
      # so let's wrap it in an As alias and call it permissions_table.
      permissible_assignments_table = Arel::Table.new(:permissions_table)
      permissible_assignments_as_table = Arel::Nodes::As.new(permissible_assignments_table, assignments_arel)

      # Build a query responsible for finding the total set of objects that
      # the user has permission on.
      # This is more than just the permissible objects.  We'll filter out the
      # objects that are not allowed in the next step.
      objects_via_authorizations = ObjectsThroughAuthorizationsQuery.new(
        klass: @klass,
        target: @target,
        auth_configs: auth_configs,
        permissible_assignments_table: permissible_assignments_table
      ).to_arel

      results_with_permissions_query = ObjectsPermissibleByRequiredPermissions.new(
        klass: @klass,
        permissible_assignments_as_table: permissible_assignments_as_table,
        objects_via_authorizations: objects_via_authorizations,
        eligible_applies_to: eligible_applies_to
      )

      hydrate_objects_query = HydrateObjectsQuery.new(
        klass: klass,
        results_with_permissions_query: results_with_permissions_query,
        target: @target
      )

      HydrateObjects.new(
        query: hydrate_objects_query,
        klass: @klass,
        target: @target
      ).to_result_set
    end
  end
end
# rubocop:enable all
