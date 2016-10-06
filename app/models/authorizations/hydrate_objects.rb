module Authorizations
  class HydrateObjects
    include QueryHelpers
    attr_reader :klass, :query, :target

    def initialize(query:, klass:, target:)
      @klass = klass
      @query = query
      @target = target
    end

    def to_result_set
      @results_set ||= begin
        objects.each_with_object(Query::ResultSet.new) do |object, rs|
          permission_states = Hash.new { |h,k| h[k] = { states: [] } }

          # Permission_actions come thru as a string column, e.g:
          #   "read:*, talk:in_progress, talk:in_review, view:*, write:in_progress"
          #
          # They need to be parsed out and the permission states should be
          # grouped by their corresponding permission action.
          object.permission_actions.
            split(/\s*,\s*/).
            map { |f| f.split(/:/) }.
            each { |permission, state| permission_states[permission][:states] << state }
          rs.add_object(object, with_permissions: permission_states)
        end
      end
    end

    private

    def objects
      target.from Arel.sql("(#{query.to_sql}) AS #{klass.table_name} ")
    end
  end
end
