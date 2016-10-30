namespace 'nested-questions:seed' do
  task 'early-posting-task': :environment do
    questions = []
    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::EarlyPostingTask.name,
      ident: "early-posting--consent",
      value_type: "boolean",
      text: "Yes, I agree to publish an early version of my article",
      position: 1
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::EarlyPostingTask.name
    ).update_all_exactly!(questions)
  end
end
