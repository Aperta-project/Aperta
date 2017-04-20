module Authorizations
  # This class defines permission "filters" that can be used to filter the scope
  # of a given permission.
  #
  # It must be used with the Authorizations configuration class.
  #
  # It takes 3 arguments: a class for which this filter applies, a column name
  # on the permissions table, and a block that will be called with a query, an
  # arel column (on the permissions table) and an arel table for the model that
  # the filter applies to.
  #
  # Example:
  # ```
  # Authorizations.configure do |config|
  #   config.filter(Task, :filter_by_name) do |query, column, table|
  #     query.where(column.eq(nil).or(column.eq(table[:name])))
  #   end
  # end
  # ```
  #
  # This means that if the column `filter_by_name` is set on a permission, and
  # the applies_to for that that permissions is `Task`, then the permission will
  # only match Tasks when the `permissions.filter_by_name` column is NULL or the
  # `permissions.filter_by_name` column is equal to the `tasks.name` column.
  #
  # This system is used by the Card Configuration system.
  #
  # DEBT: In the future, it would be possible to replace both the STI and states
  # matching logic for permissions with this flexible system.
  class Filter
    attr_reader :column_name, :block

    def initialize(klass:, column_name:, block:)
      # We're storing this as string since Ruby changes object_id on reload
      @klass = klass.to_s
      @column_name = column_name
      @block = block
    end

    def klass
      @klass.constantize
    end
  end
end
