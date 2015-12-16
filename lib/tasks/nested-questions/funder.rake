namespace 'nested-questions:seed' do
  task funder: :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::Funder.name,
      ident: "funder--had_influence",
      value_type: "boolean",
      text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
      position: 1,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::Funder.name,
          ident: "funder--had_influence--role_description",
          value_type: "text",
          text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript.",
          position: 1
        }
      ]
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::Funder.name
    ).update_all_exactly!(questions)
  end
end
