module Authorizations
  class ObjectsAuthorizedViaSelfQuery
    attr_reader :target, :assignments_table,
      :common_query, :common_arel, :klass

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
    end

    def to_sql
      to_arel.to_sql
    end
  end
end
