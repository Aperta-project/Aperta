# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class Sampler < Base
      def self.name
        "Card Configuration Sampler"
      end

      def self.view_role_names
        :all
      end

      def self.edit_role_names
        :all
      end

      def self.view_discussion_footer_role_names
        :all
      end

      def self.edit_discussion_footer_role_names
        :all
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        true
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
