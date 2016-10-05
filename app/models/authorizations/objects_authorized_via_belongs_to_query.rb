module Authorizations
  class ObjectsAuthorizedViaBelongsToQuery
    attr_reader :auth_config, :target, :assignments_table,
      :common_query, :common_arel

    def initialize(auth_config:, target:, assignments_table:, klass:)
      @auth_config = auth_config
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @common_arel = common_query.to_arel
      @target = target
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      query = common_arel.outer_join(common_query.join_table).on(
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
