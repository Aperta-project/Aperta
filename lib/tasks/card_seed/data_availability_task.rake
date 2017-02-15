# coding: utf-8
require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'data_availability_task': :environment do
    content = []
    content << {
      ident: "data_availability--data_fully_available",
      value_type: "boolean",
      text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?"
    }
    content << {
      ident: "data_availability--data_location",
      value_type: "text",
      text: "Please describe where your data may be found, writing in full sentences."
    }
    content << {
      ident: "data_availability--additional_information_doi",
      value_type: "boolean",
      text: "Tick here if the URLs/accession numbers/DOIs will be available only after acceptance of the manuscript for publication so that we can ensure their inclusion before publication.",
    }
    content << {
      ident: "data_availability--additional_information_other",
      value_type: "boolean",
      text: "Tick here if your circumstances are not covered by the content above and you need the journal’s help to make your data available."
    }

    CardSeeder.seed_card('TahiStandardTasks::DataAvailabilityTask', content)
  end
end
