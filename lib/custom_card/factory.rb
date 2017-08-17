module CustomCard
  # The purpose of this class is to create a new custom Card using a
  # configuration class that is specified in lib/custom_card/configurations
  #
  # This class abstracts the complexities involved with:
  # - card naming
  # - creating CardContent using card XML
  # - setting proper card permissions
  # - auto-publishing
  # - allowing cards to be loaded only in non-production environments

  # rubocop:disable Style/IfUnlessModifier, Metrics/LineLength
  class Factory
    attr_accessor :journal

    def initialize(journal:)
      @journal = journal
    end

    def first_or_create(configurations)
      Array(configurations).map do |configuration|
        if Rails.env.production? && configuration.do_not_create_in_production_environment
          # this card should only be loaded in non-production environments
          Rails.logger.info "Card configuration with name '#{configuration.name}' should not be loaded in production environments, skipping."
          next
        end

        if card = Card.find_by(name: configuration.name, journal: journal)
          # return, but never update an existing card, too many business decisions to handle
          Rails.logger.info "Card with name '#{configuration.name}' already exists for journal #{journal.id}, skipping."
          card
        else
          # create a new card
          create_from_configuration_klass(configuration)
        end
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
                             role_names: configuration.view_role_names)

        # set any default EDIT permissions
        set_role_permissions(card: card,
                             action: "edit",
                             role_names: configuration.edit_role_names)

        # set any default DISCUSSION VIEW permissions
        set_role_permissions(card: card,
                             action: "view_discussion",
                             role_names: configuration.discussion_view_role_names)

        # set any default DISCUSSION EDIT permissions
        set_role_permissions(card: card,
                             action: "edit_discussion",
                             role_names: configuration.discussion_edit_role_names)
      end
    end

    # rubocop:disable TernaryParentheses
    def set_role_permissions(card:, action:, role_names:)
      roles = (role_names == :all) ? Role.all : Role.where(name: Array(role_names))
      CardPermissions.set_roles(card, action, roles.uniq(:name))
    end
    # rubocop:enable TernaryParentheses
  end
  # rubocop:enable Style/IfUnlessModifier, Metrics/LineLength
end
