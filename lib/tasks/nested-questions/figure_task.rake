namespace 'nested-questions:seed' do
  task 'figure-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FigureTask.name,
      ident: "figures--complies",
      value_type: "boolean",
      text: "Yes - I confirm our figures comply with the guidelines.",
      position: 1
    }

    NestedQuestion.where(
      owner_type:  TahiStandardTasks::FigureTask.name
    ).update_all_exactly!(questions)
  end
end
