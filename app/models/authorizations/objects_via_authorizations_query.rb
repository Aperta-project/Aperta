module Authorizations

  # ObjectsViaAuthorizationsQuery represents the query responsible for finding
  # all objects through a given set of authorization pathways.
  #
  # Running an instance of this query generates a set of UNION'd queries
  # responsible for finding the @klass in question based on the provided
  # Authorizations::Authorization paths.
  #
  # == Note
  #
  # This query does not enforce permission requirements. That must be done
  # separately (see ObjectsPermissibleByRequiredPermissionsQuery).
  class ObjectsViaAuthorizationsQuery
    include QueryHelpers
    attr_reader :auth_configs, :klass, :target, :assignments_table

    # == Constructor Arguments
    # * target: the ActiveRecord::Relation that we want to query objects from
    # * klass: the type/class that is being queried against
    # * auth_configs: the collection of Authorization(s) to JOIN against
    # * assignments_table: the Arel::Table instance to be used when JOINing \
    #     and filtering against Assignment(s)
    def initialize(target:, klass:, auth_configs:, assignments_table:)
      @auth_configs = auth_configs
      @klass = klass
      @target = target
      @assignments_table = assignments_table
    end

    # This query returns more than the permissible objects.
    def to_arel
      auth_path_queries = auth_configs.map do |auth_config|
        construct_query_for_auth_config(auth_config)
      end

      union(auth_path_queries.map(&:to_arel))
    end

    def to_sql
      to_arel.to_sql
    end

    private

    # This returns a query object built specifically for the given
    # Authorizations::Authorization object.
    def construct_query_for_auth_config(auth_config)
      reflection = auth_config.reflection

      if auth_config.assignment_to <=> @klass
        ObjectsAuthorizedViaSelfQuery.new(
          target: target,
          auth_config: auth_config,
          assignments_table: assignments_table,
          klass: klass
        )

      elsif reflection.nil?
        fail MissingAssociationForAuthConfiguration, <<-ERROR.strip_heredoc
          Expected to find #{auth_config.via.inspect} association defined on
          #{auth_config.assignment_to}, but did not. This was because the following
          Authorizations::Configuration was configured:

          #{auth_config.inspect}
        ERROR

      elsif reflection.respond_to?(:through_options)
        ObjectsAuthorizedViaThroughAssociationQuery.new(
          target: target,
          auth_config: auth_config,
          assignments_table: assignments_table,
          klass: klass
        )

      elsif reflection.collection? || reflection.has_one?
        ObjectsAuthorizedViaCollectionQuery.new(
          target: target,
          auth_config: auth_config,
          assignments_table: assignments_table,
          klass: klass
        )

      elsif reflection.belongs_to?
        ObjectsAuthorizedViaBelongsToQuery.new(
          target: target,
          auth_config: auth_config,
          assignments_table: assignments_table,
          klass: klass
        )

      else
        fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
      end
    end
  end
end
