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
    class Base
      def self.name
        raise NotImplementedError
      end

      def self.excluded_view_permissions
        []
      end

      def self.excluded_edit_permissions
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
