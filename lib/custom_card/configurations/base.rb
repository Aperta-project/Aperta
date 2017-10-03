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

      # This string will be used to look up a CardTaskType with the corresponding task_class.
      # Most custom cards will default to CustomCardTask but some custom cards needing to use
      # existing functionality in our Task hierarchy will deviate.
      def self.task_class
        'CustomCardTask'
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

      def self.view_discussion_footer_role_names
        # an array of `Role.name` that should have discussion view permissions on the Card
        # default: The discussion footer is mainly for PLOS staff members.
        # options: this method can also return `:all` to allow all Roles in system
        ["Cover Editor", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Staff Admin"]
      end

      def self.edit_discussion_footer_role_names
        # an array of `Role.name` that should have discussion edit permissions on the Card
        # default: The discussion footer is mainly for PLOS staff members.
        # options: this method can also return `:all` to allow all Roles in system
        ["Internal Editor", "Production Staff", "Publishing Services", "Staff Admin"]
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

      def self.xml_content_name
        # an string of the xml file name
        to_s.demodulize.underscore + ".xml"
      end

      def self.xml_content
        # loads the XML file from the xml_content folder using the xml_content_name
        file_path = Rails.root.join("lib/custom_card/configurations/xml_content/#{xml_content_name}")

        return File.read(file_path) if File.exist?(file_path)
        raise NotImplementedError
      end
    end
  end
end
