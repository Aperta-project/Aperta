namespace 'nested-questions:seed' do
  task 'data-availability-task': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availability.data_fully_available",
      value_type: "boolean",
      text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?",
      position: 1
    )
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::DataAvailabilityTask.name,
      ident: "data_availablility.data_location",
      value_type: "text",
      text: "Please describe where your data may be found, writing in full sentences.",
      position: 2
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::DataAvailabilityTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
