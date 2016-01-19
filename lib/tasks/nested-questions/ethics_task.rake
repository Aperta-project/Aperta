namespace 'nested-questions:seed' do
  task 'ethics-task': :environment do
    questions = []
    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::EthicsTask.name,
      ident: "ethics--human_subjects",
      value_type: "boolean",
      text: "Does your study involve human participants and/or tissue?",
      position: 1,
      children: [
        {
          owner_id:nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: "ethics--human_subjects--participants",
          value_type: "text",
          text: "Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research.",
          position: 1
        }
      ]
    }

    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::EthicsTask.name,
      ident: "ethics--animal_subjects",
      value_type: "boolean",
      text: "Does your study involve animal research (vertebrate animals, embryos or tissues)?",
      position: 2,
      children: [
        {
          owner_id:nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: "ethics--animal_subjects--field_permit",
          value_type: "text",
          text: "Please enter your statement below:",
          position: 1
        },
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: 'ethics--animal_subjects--field_arrive',
          value_type: 'attachment',
          text: 'ARRIVE checklist',
          position: 2
        }
      ]
    }

    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::EthicsTask.name,
      ident: "ethics--field_study",
      value_type: "boolean",
      text: "Is this a field study, or does it involve collection of plant, animal, or other materials collected from a natural setting?",
      position: 3,
      children: [
        {
          owner_id:nil,
          owner_type: TahiStandardTasks::EthicsTask.name,
          ident: "ethics--field_study--field_permit_number",
          value_type: "text",
          text: "Please provide your field permit number and indicate the institution or relevant body that granted permission for use of the land or materials collected.",
          position: 1
        }
      ]
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::EthicsTask.name
    ).update_all_exactly!(questions)
  end
end
