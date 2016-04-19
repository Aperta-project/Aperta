namespace 'nested-questions:seed' do
  task 'data-availability-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availability--data_fully_available",
      value_type: "boolean",
      text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?",
      position: 1
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availability--data_location",
      value_type: "text",
      text: "Please describe where your data may be found, writing in full sentences.",
      position: 2
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availability--additional_information_doi",
      value_type: "boolean",
      text: "Tick here if the URLs/accession numbers/DOIs will be available only after acceptance of the manuscript for publication so that we can ensure their inclusion before publication.",
      position: 3
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availability--additional_information_other",
      value_type: "boolean",
      text: "Tick here if your circumstances are not covered by the questions above and you need the journal’s help to make your data available.",
      position: 4
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::DataAvailabilityTask.name
    ).update_all_exactly!(questions)
  end
end
