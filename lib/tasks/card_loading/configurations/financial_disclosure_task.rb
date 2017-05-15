# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
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
          text: "Did any of the authors receive specific funding for this work?",
        }
      ]
    end
  end
end
