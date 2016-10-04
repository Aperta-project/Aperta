module Authorizations
  class ObjectsAuthorizedCommonQuery
    attr_reader :auth_config, :query, :klass, :permissible_assignments_table

    def initialize(auth_config:, klass:, permissible_assignments_table:)
      @auth_config = auth_config
      @klass = klass
      @permissible_assignments_table = permissible_assignments_table
    end

    def assigned_to_klass
      auth_config.assignment_to
    end

    def join_table
      assigned_to_klass.arel_table
    end

    def target_table
      klass.arel_table
    end

    def to_arel
      permissible_assignments_table.project(
        klass.arel_table.primary_key.as('id'),
        permissible_assignments_table[:role_id].as('role_id'),
        permissible_assignments_table[:permission_id].as('permission_id')
      )
    end
  end
end
