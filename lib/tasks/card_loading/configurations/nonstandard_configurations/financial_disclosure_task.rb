# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
# This model has been deprecated as part of APERTA-10460 and once this work has
# been merged into production, it can be deleted.  This is here to ease the
# testing for spec/lib/custom_card/financial_disclosure_migrator_spec.rb
#
module CardConfiguration
  module NonstandardConfigurations
    class FinancialDisclosureTask
      def self.name
        "TahiStandardTasks::FinancialDisclosureTask"
      end

      def self.title
        "Financial Disclosure Task"
      end

      def self.content
        [
          {
            ident: "financial_disclosures--author_received_funding",
            value_type: "boolean",
            text: "Did any of the authors receive specific funding for this work?"
          }
        ]
      end
    end
  end
end
