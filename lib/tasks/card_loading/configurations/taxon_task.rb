# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class TaxonTask
    def self.name
      "TahiStandardTasks::TaxonTask"
    end

    def self.title
      "Taxon Task"
    end

    def self.content
      [
        {
          ident: "taxon--zoological",
          value_type: "boolean",
          text: "Does this manuscript describe a new zoological taxon name?",
          children: [
            {
              ident: "taxon--zoological--complies",
              value_type: "boolean",
              text: "All authors comply with the Policies Regarding Submission of a new Taxon Name"
            }
          ]
        },

        {
          ident: "taxon--botanical",
          value_type: "boolean",
          text: "Does this manuscript describe a new botanical taxon name?",
          children: [
            {
              ident: "taxon--botanical--complies",
              value_type: "boolean",
              text: "All authors comply with the Policies Regarding Submission of a new Taxon Name"
            }
          ]
        }
      ]
    end
  end
end
