# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class CompetingInterest < Base
      def self.name
        "Competing Interests"
      end

      def self.view_role_names
        ["Academic Editor",
         "Billing Staff",
         "Collaborator",
         "Cover Editor",
         "Creator",
         "Handling Editor",
         "Internal Editor",
         "Production Staff",
         "Publishing Services",
         "Reviewer",
         "Staff Admin"]
      end

      def self.edit_role_names
        ["Collaborator",
         "Cover Editor",
         "Creator",
         "Handling Editor",
         "Internal Editor",
         "Production Staff",
         "Publishing Services",
         "Staff Admin"]
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        false
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
