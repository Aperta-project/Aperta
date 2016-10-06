module Authorizations

  # ObjectsAuthorizedViaBelongsTofQuery represents the query responsible for
  # finding all authorized objects through a belongs_to associations, e.g.:
  #
  #    Authorizations::Authorization.new(
  #      assignment_to: Task,
  #      authorizes: Paper,
  #      via: :paper
  #    )
  #
  # In the above authorization Task has a belongs_to :paper association
  # for accessing its Paper. It only knows its a belongs_to association by
  # looking at up Task.reflections['paper'] definition.
  #
  # == Columns returned
  #
  # Running this query will return the following columns:
  #
  #   * <klass.table_name>.id AS id
  #   * <assignments_table>.role_id AS role_id
  #   * <assignments_table>.permission_id AS permission_table
  #
  # The < and > brackets are used above because the table references are
  # dynamic. See the corresponding constructor arguments for more information.
  #
  # == Note
  #
  # This query does not enforce permission requirements. That must be done
  # separately (see ObjectsPermissibleByRequiredPermissionsQuery).
  class ObjectsAuthorizedViaBelongsToQuery
    attr_reader  :assignments_table, :auth_config, :common_query, :target

    # == Constructor Arguments
    # * assignments_table: the Arel::Table reference representing the \
    #     assignments table to use for this query
    # * auth_config: the Authorization(s) path to JOIN against
    # * klass: the type/class that is being queried against
    # * target: the ActiveRecord::Relation being queried against
    def initialize(auth_config:, target:, assignments_table:, klass:)
      @auth_config = auth_config
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @target = target
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      query = common_query.to_arel

      query.outer_join(common_query.join_table).on(
        common_query.join_table.primary_key.eq(assignments_table[:assigned_to_id]).and(
          assignments_table[:assigned_to_type].eq(common_query.assigned_to_klass.base_class.name)))

      query.outer_join(common_query.target_table).on(
        common_query.join_table[auth_config.reflection.foreign_key].eq(
          common_query.target_table.primary_key
        )
      )

      common_query.add_column_condition(
        query: query,
        column: auth_config.reflection.foreign_key,
        values:  @target.where_values_hash[auth_config.reflection.foreign_key]
      )

      common_query.add_permission_state_check(query)
    end
  end
end
