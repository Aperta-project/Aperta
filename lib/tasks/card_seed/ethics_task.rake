require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'ethics_task': :environment do
    content = []
    content << {
      ident: "ethics--human_subjects",
      value_type: "boolean",
      text: "Does your study involve human participants and/or tissue?",
      children: [
        {
          ident: "ethics--human_subjects--participants",
          value_type: "text",
          text: "Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research."
        }
      ]
    }

    content << {
      ident: "ethics--animal_subjects",
      value_type: "boolean",
      text: "Does your study involve animal research (vertebrate animals, embryos or tissues)?",
      children: [
        {
          ident: "ethics--animal_subjects--field_permit",
          value_type: "text",
          text: "Please enter your statement below:"
        },
        {
          ident: 'ethics--animal_subjects--field_arrive',
          value_type: 'attachment',
          text: 'ARRIVE checklist'
        }
      ]
    }

    content << {
      ident: "ethics--field_study",
      value_type: "boolean",
      text: "Is this a field study, or does it involve collection of plant, animal, or other materials collected from a natural setting?",
      children: [
        {
          ident: "ethics--field_study--field_permit_number",
          value_type: "text",
          text: "Please provide your field permit number and indicate the institution or relevant body that granted permission for use of the land or materials collected."
        }
      ]
    }

    CardSeeder.seed_card('TahiStandardTasks::EthicsTask', content)
  end
end
