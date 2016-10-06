module Authorizations
  # The assignments table gathers all permissions, roles, and states from role assignments.
  # This table is joined with every auth_config
  class PermissibleAssignmentsQuery
    attr_reader :user, :permission, :klass, :applies_to, :auth_configs, :participations_only

    def initialize user:, permission:, klass:, applies_to:, auth_configs:, participations_only: true
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
    # and permission_states.
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

        # explicitly calling .arel rather than converting Assignment.all
        # to user.assignments. The reason is that ActiveRecord::Relation
        # will produce bind parameters that will not get handled correctly
        # when we convert to AREL queries below
        assignments.arel
      end
    end

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

    # If we're looking for the wildcard permission then we aren't interested in any one
    # permission, but all of the possible permissions
    def add_wildcard_permission(query)
      if @permission.to_sym != Permission::WILDCARD.to_sym
        query.where(Permission.arel_table[:action].eq(@permission))
      end
    end

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
