# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines a rake task loadable custom card that allows opting out of preprint
    #
    class PreprintOptOut < Base
      def self.name
        "Preprint Posting"
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
         "Site Admin",
         "Staff Admin"]
      end

      def self.edit_role_names
        ["Collaborator",
         "Creator",
         "Publishing Services",
         "Site Admin",
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
