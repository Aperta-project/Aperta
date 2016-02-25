namespace 'nested-questions:seed' do
  task author: :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: Author.name,
      ident: "author--published_as_corresponding_author",
      value_type: "boolean",
      text: "This is a post publication corresponding author",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: Author.name,
      ident: "author--deceased",
      value_type: "boolean",
      text: "This person is deceased",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: Author.name,
      ident: "author--contributions",
      value_type: "question-set",
      text: "Author Contributions",
      position: 3,
      children: [
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--conceptualization",
          value_type: "boolean",
          text: "Conceptualization",
          position: 1
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--investigation",
          value_type: "boolean",
          text: "Investigation",
          position: 2
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--visualization",
          value_type: "boolean",
          text: "Visualization",
          position: 3
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--methodology",
          value_type: "boolean",
          text: "Methodology",
          position: 4
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--resources",
          value_type: "boolean",
          text: "Resources",
          position: 5
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--supervision",
          value_type: "boolean",
          text: "Supervision",
          position: 6
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--software",
          value_type: "boolean",
          text: "Software",
          position: 7
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--data-curation",
          value_type: "boolean",
          text: "Data Curation",
          position: 8
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--project-administration",
          value_type: "boolean",
          text: "Project Administration",
          position: 9
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--validation",
          value_type: "boolean",
          text: "Validation",
          position: 10
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--writing-original-draft",
          value_type: "boolean",
          text: "Writing - Original Draft",
          position: 11
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--writing-review-and-editing",
          value_type: "boolean",
          text: "Writing - Review and Editing",
          position: 12
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--funding-acquisition",
          value_type: "boolean",
          text: "Funding Acquisition",
          position: 13
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--formal-analysis",
          value_type: "boolean",
          text: "Formal Analysis",
          position: 14
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: Author.name,
      ident: "author--government-employee",
      value_type: "boolean",
      text: "Is this author an employee of the United States Government?",
      position: 4
    }

    NestedQuestion.where(owner_type: Author.name).update_all_exactly!(questions)
  end
end
