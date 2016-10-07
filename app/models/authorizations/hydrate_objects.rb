module Authorizations

  # HydrateObjects is responsible for taking a HydrateObjectsQuery instance,
  # executing it against a given @target ActiveRecord::Relation, and
  # returning a ResultSet that contains all of ActiveRecord model instances
  # that are returned.
  class HydrateObjects
    include QueryHelpers

    attr_reader :klass, :query, :target

    # == Constructor Arguments
    # * klass: the type/class that is being queried against (e.g. Task, Paper)
    # * query: a HydratObjectsQuery instance or any query that includes a \
    #    permission_actions column
    # * target: the ActiveRecord::Relation being queried against. This will be
    #    used to further filter down the given query results.
    def initialize(query:, klass:, target:)
      @klass = klass
      @query = query
      @target = target
    end

    # Returns a ResultSet instance containing the results of the query.
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

    def to_arel
      objects.arel
    end

    def to_sql
      to_arel.to_sql
    end

    private

    # permission_actions come thru as a string column, e.g:
    #   "view:*, edit:unsubmitted, submit:unsubmitted, withdraw:submitted"
    #
    # These permission_actions need to be parsed out into a hash map that
    # groups state by their permission action. E.g.
    #
    #   {
    #     view: ['*'],
    #     edit: ['unsubmitted'],
    #     withdraw: ['unsubmitted', 'submitted', 'in_review']
    #    }
    #
    # Note: the above Hash is meant to be illustrative, not accurate.
    def convert_permission_actions_into_hash_map(permission_actions)
      permissions_map = Hash.new { |h,k| h[k] = { states: [] } }

      permission_actions.split(/\s*,\s*/).
        map { |f| f.split(/:/) }.
        each { |action, state| permissions_map[action][:states] << state }

      permissions_map
    end

    # Returns an ActiveRecord::Relation instance that combines @target
    # and the passed in @query.
    def objects
      target.from Arel.sql("(#{query.to_sql}) AS #{klass.table_name} ")
    end
  end
end
