module Authorizations
  class HydrateObjectsQuery
    include QueryHelpers

    attr_reader :select_columns, :klass, :query

    def initialize(klass:, query:, select_columns:)
      @klass = klass
      @query = query
      @select_columns = process_select_columns(select_columns)
    end

    def to_arel
      Arel::SelectManager.new(klass.arel_table.engine)
        .project(*select_columns)
        .from( Arel.sql("( #{@query.to_sql} )").as(as_table.name))
        .join(klass.arel_table).on(klass.arel_table[:id].eq(as_table[:id]))
    end

    def to_sql
      to_arel.to_sql
    end

    private

    def as_table
      @as_table ||= Arel::Table.new(:object_ids_to_hydrate)
    end

    def process_select_columns(select_columns)
      select_columns.map do |column|
        if column.is_a?(String) or column.is_a?(Symbol)
          as_table[column]
        else
          column
        end
      end
    end
  end
end
