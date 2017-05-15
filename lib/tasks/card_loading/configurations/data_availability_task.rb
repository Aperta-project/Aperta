# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class DataAvailabilityTask
    def self.name
      "TahiStandardTasks::DataAvailabilityTask"
    end

    def self.title
      "Data Availability Task"
    end

    def self.content
      [
        {
          ident: "data_availability--data_fully_available",
          value_type: "boolean",
          text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?"
        },
        {
          ident: "data_availability--data_location",
          value_type: "html",
          text: "Please describe where your data may be found, writing in full sentences."
        },
        {
          ident: "data_availability--additional_information_doi",
          value_type: "boolean",
          text: "Tick here if the URLs/accession numbers/DOIs will be available only after acceptance of the manuscript for publication so that we can ensure their inclusion before publication.",
        },
        {
          ident: "data_availability--additional_information_other",
          value_type: "boolean",
          text: "Tick here if your circumstances are not covered by the content above and you need the journal’s help to make your data available."
        }
      ]
    end
  end
end
