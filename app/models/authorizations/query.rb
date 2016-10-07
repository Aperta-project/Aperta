# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'
require_dependency 'authorizations/query/result_set'

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
  # == Deep Dive!
  #
  # The query generates _a lot_ of SQL. The SQL looks complex, but it's
  # conceptually pretty simple. There are four things that need to be done.
  # Consider this code:
  #
  #       Authorizations::Query.new(
  #         user: User.find_by_username("joe"),
  #         permission: :view,
  #         target: Paper.find(99).tasks
  #       ).all
  #
  #    Joe is trying to get a list of all of the tasks on Paper 99 that he
  #    can view. Here are the four steps we need to consider:
  #
  # ==== Step 1
  #
  # For a given user and permission we need to find all of the \
  # Assignment(s) that could give the user access to kind of object \
  # (e.g. Task, Paper, Journal, etc).
  #
  # This means that we need to find all assignments for Joe, JOIN on
  # roles, JOIN on permissions, JOIN on permission_states and then only include
  # those records where the permissions.applies_to matches Paper.
  #
  # Remember, this is just to get a list of Assignment(s) that _might_ give Joe
  # access. We don't know for sure yet, onto step 2.
  #
  # Note: the PermissibleAssignmentsQuery represents Step 1.
  #
  # ==== Step 2
  #
  # Once we have the set of assignments which could give a user access to an \
  # an object we need to then look at all of the Authorization paths. The
  # Authorization paths tell us how to get from the kind of object the user
  # is assigned to, to the kind of object that the user is querying for.
  #
  # There may be multiple paths. For example, if Joe was looking to access
  # Paper 99 he may be assigned to a Journal. If so, then the path may be
  # the Journal's "has_many :papers" association, but if Joe is assigned
  # to a Task (say he's a Reviewer assigned to a ReviewerReportTask) then the
  # path may be thru Task's "belongs_to :paper" association.
  #
  # Because there are many ways to get from point A (what the user is \
  # assigned to) to point B (what the user is querying for) we need to
  # dynamically query all of those paths because we don't know ahead of time
  # which path will give him access.
  #
  # Once we look at all of the paths we will the set of the objects that
  # Joe is authorized to view. Well mostly. Up until know we haven't taken
  # into consideration PermissionRequirement(s). Let's do that next.
  #
  # Note: the ObjectsViaAuthorizationsQuery represents Step 2. Internally,
  # it will use ObjectsAuthorizedViaNNNQuery objects to do the heavy
  # lifting where NNN is BelongsTo, Collection, Self, or Through.
  #
  # ==== Step 3
  #
  # Now that we have all of the objects that a user may be authorized to see
  # we need to further reduce the results to exclude any that have
  # PermissionRequirement(s) that the user doesn't have.
  #
  # The result of this is final set of objects that a user can see. For Joe,
  # it would be a list of all of the tasks he could view on Paper 99.
  #
  # At this point we have a set of records which contains two key pieces of
  # information: the object id and the permission actions. E.g. we may have
  # a result set that looks like this:
  #
  #     id       permission_actions
  #   ------  |  -------------------
  #      11   |    view:*, edit: unsubumitted
  #      47   |    view:*, edit: unsubmitted
  #      33   |    view:*, edit: unsubmitted
  #
  # Note: the ObjectsPermissibleByRequiredPermissionsQuery handles this work.
  #
  # ==== Step 4
  #
  # Up to this point all of the queries and subqueries have used only the
  # columns that they need to do their job. This wasn't mentioned earlier in
  # these docs because it didnt' seem relevant. Now it's relevant.
  #
  # If you look at the table of results in Step 3 above there are only
  # two fields. We need to take the tasks that Joe can view and hydrate
  # them. So, step 4 involves JOINing those ids back on the tasks table
  # and selecting _all_ of the columns.
  #
  # That's all step 4 does.
  #
  # Note: HydrateObjectsQuery and HydrateObjects handle step 4.
  #
  # ==== Summary
  #
  # There are parts of the Authorization query which are static and there
  # are parts which are dynamic. The code to generate the dynamic bits does
  # get a bit messy because it is doing some complicated things (converting
  # Ruby code to efficient SQL code), but in reality only the four steps
  # above are being applied.
  #
  # P.S. This code works with Single Table Inheritance (STI) and that is
  # an area that also makes some Ruby code more cmoplex as well as the
  # resulting SQL complex. Fortunately, it's not a problem for the database.
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

    def to_arel
      load_authorized_objects_query.to_arel
    end

    def to_sql
      to_arel.to_sql
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

      load_authorized_objects_query.to_result_set
    end

    # Takes a query object and hydrates it returning a HydratesObject
    # instance.
    def hydrate_objects_from_query(query_to_hydrate)
      hydrate_objects_query = HydrateObjectsQuery.new(
        klass: klass,
        query: query_to_hydrate,
        select_columns: [ klass.arel_table[Arel.star], :permission_actions ]
      )

      HydrateObjects.new(
        query: hydrate_objects_query,
        klass: @klass,
        target: @target
      )
    end

    def load_authorized_objects_query
      @load_authorized_objects_query ||= begin
        hydrate_objects_from_query(results_with_permissions_query)
      end
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
