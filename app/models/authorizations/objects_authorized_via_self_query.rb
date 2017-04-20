module Authorizations

  # ObjectsAuthorizedViaSelfQuery represents the query responsible for finding
  # all authorized objects through a self-reference, e.g.:
  #
  #    Authorizations::Authorization.new(
  #      assignment_to: Paper,
  #      authorizes: Paper,
  #      via: :self
  #    )
  #
  # A self-reference means that the thing a user is assigned to is the same
  # type of thing that it authorizes.
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
  class ObjectsAuthorizedViaSelfQuery
    attr_reader :target, :assignments_table, :common_query, :common_arel, :klass

    # == Constructor Arguments
    # * assignments_table: the Arel::Table reference representing the \
    #     assignments table to use for this query
    # * auth_config: the Authorization(s) path to JOIN against
    # * klass: the type/class that is being queried against
    # * target: the ActiveRecord::Relation being queried against
    def initialize(auth_config:, target:, assignments_table:, klass:)
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @common_arel = common_query.to_arel
      @target = target
      @klass = klass
    end

    def to_arel
      query = common_arel.outer_join(common_query.join_table).on(
        common_query.join_table.primary_key.eq(assignments_table[:assigned_to_id]).and(
          assignments_table[:assigned_to_type].eq(common_query.assigned_to_klass.base_class.name)
        )
      )

      common_query.add_column_condition(
        query: query,
        column: common_query.join_table.primary_key,
        values:  @target.where_values_hash[klass.primary_key]
      )

      common_query.add_permission_state_check(query)
      common_query.add_filter_by_check(query)
    end

    def to_sql
      to_arel.to_sql
    end
  end
end
