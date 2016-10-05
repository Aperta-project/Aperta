module Authorizations
  class HydrateObjectsQuery
    include QueryHelpers
    attr_reader :klass, :objects_with_permissions_query, :target

    def initialize(klass:, objects_with_permissions_query:, target:)
      @klass = klass
      @objects_with_permissions_query = objects_with_permissions_query
      @target = target
    end

    def to_arel
      Arel::SelectManager.new(klass.arel_table.engine).
        project(klass.arel_table[Arel.star], 'permission_actions').
        from( Arel.sql('(' + objects_with_permissions_query.to_sql + ')').as('results_with_permissions') ).
        join(klass.arel_table).on(klass.arel_table[:id].eq(table[:results_with_permissions][:id]))
    end

    def to_sql
      to_arel.to_sql
    end
  end
end

