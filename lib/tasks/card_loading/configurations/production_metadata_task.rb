# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ProductionMetadataTask
    def self.name
      "TahiStandardTasks::ProductionMetadataTask"
    end

    def self.title
      "Production Metadata Task"
    end

    def self.content
      [
        {
          ident: "production_metadata--publication_date",
          value_type: "text",
          text: "Publication Date"
        },

        {
          ident: "production_metadata--volume_number",
          value_type: "text",
          text: "Volume Number"
        },

        {
          ident: "production_metadata--issue_number",
          value_type: "text",
          text: "Issue Number"
        },

        {
          ident: "production_metadata--provenance",
          value_type: "text",
          text: "Provenance"
        },

        {
          ident: "production_metadata--production_notes",
          value_type: "text",
          text: "Production Notes"
        },

        {
          ident: "production_metadata--special_handling_instructions",
          value_type: "text",
          text: "Special Handling Instructions"
        }
      ]
    end
  end
end
