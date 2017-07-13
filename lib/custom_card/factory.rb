module CustomCard
  class Factory
    attr_accessor :journal

    def initialize(journal:)
      @journal = journal
    end

    def create(configurations)
      Array(configurations).map do |configuration|
        if Card.exists?(name: configuration.name, journal: journal)
          # do not update an existing card, too many business decisions to handle
          Rails.logger.info "Card with name '#{configuration.name}' already exists for journal #{journal.id}, skipping."
          next
        end

        if Rails.env.production? && configuration.do_not_create_in_production_environment
          # this card should only be loaded in non-production environments
          Rails.logger.info "Card configuration with name '#{configuration.name}' should not be loaded in production environments, skipping."
          next
        end

        create_from_configuration_klass(configuration)
      end
    end

    private

    def create_from_configuration_klass(configuration)
      Card.create_initial_draft!(name: configuration.name, journal: journal).tap do |card|
        # build card content using xml
        card.update_from_xml(configuration.xml_content)

        # set published flag
        if configuration.publish
          card.reload.publish!('Initial version')
        end

        # set any default VIEW permissions
        set_role_permissions(card: card,
                             action: "view",
                             excluded_role_names: configuration.excluded_view_permissions)

        # set any default EDIT permissions
        set_role_permissions(card: card,
                             action: "edit",
                             excluded_role_names: configuration.excluded_edit_permissions)
      end
    end

    def set_role_permissions(card:, action:, excluded_role_names: [])
      role_names = journal.roles.pluck(:name) - Array(excluded_role_names)
      CardPermissions.set_roles(card, action, Role.where(name: role_names))
    end
  end
end
