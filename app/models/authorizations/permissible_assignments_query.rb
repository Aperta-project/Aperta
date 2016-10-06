module Authorizations

  # PermissibleAssignmentsQuery represents the query responsible for finding
  # all Assignment(s) that have a given permission for a collection of
  # types/classes.
  #
  # == Columns returned
  #
  # Running this query will return the following columns:
  #
  #   * assignments.id AS id
  #   * assignments.assigned_to_type AS assigned_to_type
  #   * assignments.assigned_to_id AS assigned_to_id
  #   * roles.id AS role_id
  #   * roles.name AS role_name
  #   * permissions.id AS permission_id
  #
  # This query will also GROUP BY the following columns to ensure that
  # we do not have duplicate assignments <-> roles <-> permissions records
  # returned:
  #
  #   * assignments.assigned_to_type
  #   * assignments.assigned_to_id
  #   * assignments.id
  #   * roles.id
  #   * permissions.id
  #
  class PermissibleAssignmentsQuery
    attr_reader :user, :permission, :klass, :applies_to, :auth_configs, :participations_only

    # == Constructor Arguments
    # * user: the user who the query will be check for authorization against
    # * permission: the permission action to check against, e.g. :view
    # * klass: the type/class that is being queried against
    # * applies_to: the collection of types/classes that should be included \
    #     when checking against the permissions table
    # * auth_configs: the collection of Authorization(s) to JOIN against
    # * participations_only: a boolean specifying if only targets a user \
    #     participates in should be returned.
    def initialize(user:, permission:, klass:, applies_to:, auth_configs:, participations_only:)
      @user = user
      @permission = permission
      @klass = klass
      @applies_to = applies_to
      @auth_configs = auth_configs
      @participations_only = participations_only
    end

    def to_arel
      return @query if @query

      @query = base_query

      add_auth_config_joins(@query)
      add_auth_config_conditions(@query)
      add_wildcard_permission(@query)
      add_participations_only(@query)

      @query.group(Assignment.arel_table[:assigned_to_type])
        .group(Assignment.arel_table[:assigned_to_id])
        .group(Assignment.arel_table[:id])
        .group(Role.arel_table[:id])
        .group(Permission.arel_table[:id])
    end

    def to_sql
      to_arel.to_sql
    end

    private

    # Returns an AREL AST which represents a basic query for finding
    # all assignments for a user joining on their roles, permissions,
    # and permission_states. This is a static part of this query with the
    # user.id being the only dynamic bit.
    def base_query
      @base_query ||= begin
        # In the beginning we cheat by using ActiveRecord to reduce the
        # amount of AREL code we have to write. We will convert to AREL
        # below.
        assignments = Assignment.all
          .select('
            assignments.id,
            assignments.assigned_to_type,
            assignments.assigned_to_id,
            roles.id AS role_id,
            roles.name AS role_name,
            permissions.id AS permission_id'
          )
        .joins(permissions: :states)
        .where(assignments: { user_id: user.id })

        # explicitly call .arel rather than convert Assignment.all
        # to user.assignments. The reason is that ActiveRecord::Relation
        # will produce bind parameters that will not get handled correctly
        # when AREL is asked to generate SQL
        assignments.arel
      end
    end

    # This loops over all of the authorization paths and adds a
    # LEFT OUTER JOIN from the assignments table. This is a dynamic part of the
    # the query.
    #
    # == Example of SQL Generated
    #
    #   LEFT JOIN "journals" on "journals"."id" = "assignments"."assigned_to_id"
    #     AND "assignments"."assigned_to_type" = 'Journal'
    #   LEFT JOIN "papers" on "papers"."id" = "assignments"."assigned_to_id"
    #     AND "assignments"."assigned_to_type" = 'Paper'
    #   LEFT JOIN "tasks" on "tasks"."id" = "assignments"."assigned_to_id"
    #     AND "assignments"."assigned_to_type" = 'Task'
    #
    # == Note:
    #
    # Do not use an INNER JOIN here because the authorization paths may look at
    # at different tables, meaning only one of those tables will have have
    # results. We'll filter in the method: add_auth_config_conditions.
    def add_auth_config_joins(query)
      auth_configs.each do |ac|
        join_table = ac.assignment_to.arel_table
        source_table = ac.authorizes.arel_table
        association = ac.assignment_to.reflections[ac.via.to_s]

        query.outer_join(join_table).on(
          join_table[ ac.assignment_to.primary_key ]
            .eq( Assignment.arel_table[:assigned_to_id] )
          .and(
             Assignment.arel_table[:assigned_to_type].
             eq(ac.assignment_to.base_class.name)
          )
        )
      end
    end

    # Whereas add_auth_config_joins adds the JOINs for the authorization
    # paths this adds the WHERE conditions for those JOINs. It loops over
    # the authorization paths and filters out any rows that do not have one
    # e primary key value populated for the JOINed records.
    #
    # == Example of SQL Generated
    #   (
    #     (
    #      "journals"."id" is not null
    #       OR "papers"."id" is not null
    #     )
    #     OR "tasks"."id" is not null
    #   )
    #
    def add_auth_config_conditions(query)
      arel_conditions = auth_configs.reduce(nil) do |conditions, ac|
        if conditions
          conditions.or(
            ac.assignment_to .arel_table.primary_key.not_eq(nil)
          )
        else
          ac.assignment_to.arel_table.primary_key.not_eq(nil)
        end
      end

      query
        .where(arel_conditions)
        .where(Permission.arel_table[:applies_to].in(applies_to))
    end

    # If we're looking for the wildcard permission then we aren't interested
    # in any one permission, but all of the possible permissions. When we're not
    # looking for the wildcard permission then add a new condition the
    # WHERE clause.
    #
    # == Example of SQL Generated
    #
    #   "permissions"."action" = 'view'
    #
    def add_wildcard_permission(query)
      if @permission.to_sym != Permission::WILDCARD.to_sym
        query.where(Permission.arel_table[:action].eq(@permission))
      end
    end

    # If @participations_only is true then check to see if any of the roles
    # the user is assigned to have a participates_in_NNN column. If so,
    # add a WHERE clause condition that filters out records that do not have
    # that column set to true.
    #
    # == Example of SQL Generated
    #
    #   "roles"."participates_in_papers" = 't'
    #
    def add_participations_only(query)
      if @participations_only
        role_accessibility_method = "participates_in_#{@klass.table_name}"
        if Role.column_names.include?(role_accessibility_method)
          query.where(Role.arel_table[role_accessibility_method.to_sym].eq(true))
        end
      end
    end
  end
end
