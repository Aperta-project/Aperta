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
      auth_configs.map do |ac|
        assigned_to_klass = ac.assignment_to
        reflection = ac.assignment_to.reflections[ac.via.to_s]

        if assigned_to_klass <=> @klass
          ObjectsAuthorizedViaSelf.new(
            target: target,
            auth_config: ac,
            permissible_assignments_table: permissible_assignments_table,
            klass: klass
          ).to_arel

        elsif reflection.nil?
          fail MissingAssociationForAuthConfiguration, <<-ERROR.strip_heredoc
            Expected to find #{ac.via.inspect} association defined on
            #{assigned_to_klass}, but did not. This was because the following
            Authorizations::Configuration was configured:

            #{ac.inspect}
          ERROR

        elsif reflection.respond_to?(:through_options)
          ObjectsAuthorizedViaThroughAssociation.new(
            target: target,
            auth_config: ac,
            permissible_assignments_table: permissible_assignments_table,
            klass: klass
          ).to_arel

        elsif reflection.collection? || reflection.has_one?
          ObjectsAuthorizedViaCollection.new(
            target: target,
            auth_config: ac,
            permissible_assignments_table: permissible_assignments_table,
            klass: klass
          ).to_arel
        elsif reflection.belongs_to?
          ObjectsAuthorizedViaBelongsTo.new(
            target: target,
            auth_config: ac,
            permissible_assignments_table: permissible_assignments_table,
            klass: klass
          ).to_arel
        else
          fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
        end
      end
    end
  end
end
