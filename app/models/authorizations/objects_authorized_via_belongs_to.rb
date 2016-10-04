module Authorizations
  class ObjectsAuthorizedViaBelongsTo
    attr_reader :target, :permissible_assignments_table,
      :common_query, :common_arel

    def initialize(auth_config:, target:, permissible_assignments_table:, klass:)
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        permissible_assignments_table: permissible_assignments_table
      )
      @permissible_assignments_table = permissible_assignments_table
      @common_arel = common_query.to_arel
      @target = target
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      query = common_arel.outer_join(common_query.join_table)
        .on(common_query.join_table.primary_key.eq(permissible_assignments_table[:assigned_to_id])
        .and(permissible_assignments_table[:assigned_to_type].eq(common_query.assigned_to_klass.base_class.name)))

      query.outer_join(common_query.target_table).on(common_query.join_table[common_query.reflection.foreign_key].eq(common_query.target_table.primary_key))

      foreign_key_value = @target.where_values_hash[common_query.reflection.foreign_key]
      if foreign_key_value
        foreign_key_values = [ foreign_key_value ].flatten
        query.where(common_query.join_table.primary_key.in(foreign_key_values))
      end

      common_query.add_permission_state_check_to_query(query)
    end
  end
end
