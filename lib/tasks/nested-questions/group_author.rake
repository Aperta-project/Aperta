namespace 'nested-questions:seed' do
  task 'group-author': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: GroupAuthor.name,
      ident: "group-author--contributions",
      value_type: "question-set",
      text: "Author Contributions",
      position: 1,
      children: [
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--conceptualization",
          value_type: "boolean",
          text: "Conceptualization",
          position: 1
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--investigation",
          value_type: "boolean",
          text: "Investigation",
          position: 2
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--visualization",
          value_type: "boolean",
          text: "Visualization",
          position: 3
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--methodology",
          value_type: "boolean",
          text: "Methodology",
          position: 4
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--resources",
          value_type: "boolean",
          text: "Resources",
          position: 5
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--supervision",
          value_type: "boolean",
          text: "Supervision",
          position: 6
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--software",
          value_type: "boolean",
          text: "Software",
          position: 7
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--data-curation",
          value_type: "boolean",
          text: "Data Curation",
          position: 8
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--project-administration",
          value_type: "boolean",
          text: "Project Administration",
          position: 9
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--validation",
          value_type: "boolean",
          text: "Validation",
          position: 10
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--writing-original-draft",
          value_type: "boolean",
          text: "Writing - Original Draft",
          position: 11
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--writing-review-and-editing",
          value_type: "boolean",
          text: "Writing - Review and Editing",
          position: 12
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--funding-acquisition",
          value_type: "boolean",
          text: "Funding Acquisition",
          position: 13
        },
        {
          owner_id: nil,
          owner_type: GroupAuthor.name,
          ident: "group-author--contributions--formal-analysis",
          value_type: "boolean",
          text: "Formal Analysis",
          position: 14
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: GroupAuthor.name,
      ident: "group-author--government-employee",
      value_type: "boolean",
      text: "Is this group a United States Government agency, department or organization?",
      position: 2
    }

    NestedQuestion.where(owner_type: GroupAuthor.name).update_all_exactly!(questions)
  end
end
