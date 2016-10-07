module Authorizations

  # HydrateObjectsQuery is responsible for hydrating all of the rows
  # for the @klass being queried.
  #
  # For example, this object expects a query that returns at least one
  # column: id.
  #
  # The +id+ should be the primary key a record represented by @klass. So if
  # @klass is Task then the +id+ column should be values from tasks.id.
  #
  # How this works in the grand scheme of things is this: A bunch of other
  # queries take place before this to determine what records a user is
  # authorized to see. To keep queries as fast as possible they only select
  # the information necessary to determine access. Once we have that final
  # list of accessible rows we now need to JOIN back on the source table
  # (e.g. @klass.table_name) and get all of the other columsn/properties.
  #
  # == Pass-thru Columns
  #
  # If the incoming query has more columns available then also pass in
  # the +select_columns+ argument to the constructor to have them
  # selected and passed thru.
  #
  class HydrateObjectsQuery
    include QueryHelpers

    attr_reader :select_columns, :klass, :query

    # == Constructor Arguments
    # * klass: the type/class that is being queried against (e.g. Task, Paper)
    # * query: an object that responds to #to_sql and selects at least the
    #     +id+ column. The +id+ values will be used to JOIN against
    #     @klass's underlying table and populate columns. See above class docs
    #     for more information.
    # * select_columns: a collection of columns to select/project from the
    #     results of this query.
    #
    # == select_columns: Arel columns or String/Symbol
    #
    # The +select_columns+ collection can contain Arel column references or
    # String/Symbol references. If the value is a String or Symbol it will
    # be converted to pull from a column on the passed in query. Otherwise it
    # will be left alone assuming the caller knows exactly what they want.
    #
    # For example, say @klass is Task and the query provided represents
    # all tasks we are interested in and that that select_columns is:
    #
    #    [Arel::Table.new(:tasks)[Arel.star], :permission_actions]
    #
    # This generates a SELECT statement that looks like:
    #
    #    SELECT tasks.*, object_ids_to_hydrate.permission_actions
    #
    # The object_ids_to_hydrate table is an internal table alias for the
    # the +query+ passed in. So what we've really done is passed thru the
    # permission_actions column from the passed in +query+ to the results
    # of this hydrating query. Neat stuff, right?
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

    # Returns the Arel::Table instance responsible for aliasing the
    # @query. This is so we can treat @query as a sub-query. E.g.:
    #
    #     (SELECT * FROM ... WHERE ... ) AS object_ids_to_hydrate
    def as_table
      @as_table ||= Arel::Table.new(:object_ids_to_hydrate)
    end

    # Takes in a collection of possible column references (Arel columns,
    # Strings, or Symbols) and returns a collection of all Arel column
    # references.
    #
    # This will not touch Arel column references coming in, but will
    # convert all String/Symbol(s) to be columns on the +as_table+.
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
