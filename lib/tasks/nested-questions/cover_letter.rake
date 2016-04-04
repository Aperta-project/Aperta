namespace 'nested-questions:seed' do
  task 'cover-letter-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::CoverLetterTask.name,
      ident: "cover_letter--text",
      value_type: "text",
      position: 1
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::CoverLetterTask.name,
      ident: "cover_letter--attachment",
      value_type: "attachment",
      position: 2
    }
    NestedQuestion.where(
      owner_type: TahiStandardTasks::CoverLetterTask.name
    ).update_all_exactly!(questions)
  end
end
