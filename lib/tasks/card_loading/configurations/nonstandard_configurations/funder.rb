# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
# This model has been deprecated as part of APERTA-10460 and once this work has
# been merged into production, it can be deleted.  This is here to ease the
# testing forpec/lib/custom_card/financial_disclosure_migrator_spec.rb
#

module CardConfiguration
  module NonstandardConfigurations
    class Funder
      def self.name
        "TahiStandardTasks::Funder"
      end

      def self.title
        "Funder"
      end

      def self.content
        [
          {
            ident: "funder--had_influence",
            value_type: "boolean",
            text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
            children: [
              {
                ident: "funder--had_influence--role_description",
                value_type: "text",
                text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript."
              }
            ]
          }
        ]
      end
    end
  end
end
