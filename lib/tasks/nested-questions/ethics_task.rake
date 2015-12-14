namespace 'nested-questions:seed' do
  task 'ethics-task': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::EthicsTask.name,
      ident: "ethics--human_subjects",
      value_type: "boolean",
      text: "Does your study involve Human Subject Research (human participants and/or tissue)?",
      position: 1,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: "ethics--human_subjects--participants",
          value_type: "text",
          text: "Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research.",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::EthicsTask.name,
      ident: "ethics--animal_subjects",
      value_type: "boolean",
      text: "Does your study involve Animal Research (vertebrate animals, embryos or tissues)?",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: "ethics--animal_subjects--field_permit",
          value_type: "text",
          text: "Please enter your statement below:",
          position: 1
        )
      ]
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::EthicsTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
