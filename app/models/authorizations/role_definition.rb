module Authorizations
  # RoleDefinition represents the definition a role. It is used for building
  # up role definitions that can be imported with Authorizations::RoleImporter
  # efficiently.
  class RoleDefinition
    attr_accessor :name, :journal, :participates_in, :permission_definitions

    def self.ensure_exists(name, journal: nil, participates_in: [], &block)
      role_definition = new(
        name: name,
        journal: journal,
        participates_in: participates_in
      )
      yield role_definition if block
      role_definition.ensure_exists!
    end

    def initialize(name:, journal:, participates_in: [])
      @name = name
      @journal = journal
      @participates_in = participates_in || []

      whitelist = [::Task, ::Paper]
      fail StandardError, "Bad participates_in: #{participates_in}" unless \
        ((whitelist | participates_in) == whitelist)

      @permission_definitions = []
    end

    def ensure_exists!
      RoleImporter.new(self).import!
    end

    def ensure_permission_exists(action, applies_to:, states: [Permission::WILDCARD])
      if applies_to.is_a?(Class) && applies_to.try(:name).nil?
        Rails.logger.warn <<-WARN
          Skipping #ensure_permission_exists for a class without a name. If
          this is in the test environment it can be safely ignored as this
          happens when anonymous subclasses are created for tests.
        WARN
      else
        @permission_definitions << PermissionDefinition.new(
          action: action.to_s,
          applies_to: (applies_to.try(:name) || applies_to),
          states: states.map(&:to_s).sort
        )
      end
    end
  end
end
