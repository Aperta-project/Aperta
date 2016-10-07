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
          permissions_map = convert_permission_actions_into_hash_map(
            object.permission_actions
          )
          rs.add_object(object, with_permissions: permissions_map)
        end
      end
    end

    private

    def objects
      target.from Arel.sql("(#{query.to_sql}) AS #{klass.table_name} ")
    end
    def convert_permission_actions_into_hash_map(permission_actions)
      permissions_map = Hash.new { |h,k| h[k] = { states: [] } }

      permission_actions.split(/\s*,\s*/).
        map { |f| f.split(/:/) }.
        each { |action, state| permissions_map[action][:states] << state }

      permissions_map
    end
  end
end
