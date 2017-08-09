# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    # All Configuration classes will descend from this base class.
    #
    # WARNING:  If this base class is modified, please update the
    # rails generator template here:
    #
    # lib/generators/custom_card/configuration/templates/configuration.template
    #
    class Base
      def self.name
        raise NotImplementedError
      end

      def self.view_role_names
        # an array of `Role.name` that should have view access to Card
        # default: no access
        # options: this method can also return `:all` to allow all Roles in system
        []
      end

      def self.edit_role_names
        # an array of `Role.name` that should have edit access to Card
        # default: no access
        # options: this method can also return `:all` to allow all Roles in system
        []
      end

      def self.excluded_discussion_view_permissions
        []
      end

      def self.excluded_discussion_edit_permissions
        []
      end

      def self.publish
        # true:  auto publish card when created
        # false: leave card as a draft
        true
      end

      def self.do_not_create_in_production_environment
        # true:  load in all environments
        # false: load only in non-production environments
        false
      end

      def self.xml_content
        raise NotImplementedError
      end
    end
  end
end
