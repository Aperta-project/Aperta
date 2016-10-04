module Authorizations
  class ObjectsThroughAuthorizationsQuery
    include QueryHelpers
    attr_reader :auth_configs, :klass, :target, :permissible_assignments_table

    def initialize(target:, klass:, auth_configs:, permissible_assignments_table:)
      @auth_configs = auth_configs
      @klass = klass
      @target = target
      @permissible_assignments_table = permissible_assignments_table
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      auth_configs.map do |auth_config|
        construct_query_for_auth_config(auth_config)
      end
    end

    private

    def construct_query_for_auth_config(auth_config)
      reflection = auth_config.reflection

      if auth_config.assignment_to <=> @klass
        ObjectsAuthorizedViaSelf.new(
          target: target,
          auth_config: auth_config,
          permissible_assignments_table: permissible_assignments_table,
          klass: klass
        ).to_arel

      elsif reflection.nil?
        fail MissingAssociationForAuthConfiguration, <<-ERROR.strip_heredoc
          Expected to find #{auth_config.via.inspect} association defined on
          #{auth_config.assignment_to}, but did not. This was because the following
          Authorizations::Configuration was configured:

          #{auth_config.inspect}
        ERROR

      elsif reflection.respond_to?(:through_options)
        ObjectsAuthorizedViaThroughAssociation.new(
          target: target,
          auth_config: auth_config,
          permissible_assignments_table: permissible_assignments_table,
          klass: klass
        ).to_arel

      elsif reflection.collection? || reflection.has_one?
        ObjectsAuthorizedViaCollection.new(
          target: target,
          auth_config: auth_config,
          permissible_assignments_table: permissible_assignments_table,
          klass: klass
        ).to_arel

      elsif reflection.belongs_to?
        ObjectsAuthorizedViaBelongsTo.new(
          target: target,
          auth_config: auth_config,
          permissible_assignments_table: permissible_assignments_table,
          klass: klass
        ).to_arel

      else
        fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
      end
    end
  end
end
