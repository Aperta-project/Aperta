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

    NestedQuestion.where(
      owner_type: TahiStandardTasks::DataAvailabilityTask.name
    ).update_all_exactly!(questions)
  end
end
