namespace 'card_seed' do
  task 'group_author': :environment do
    content = []

    content << {
      ident: "group-author--contributions",
      value_type: "question-set",
      text: "Author Contributions",
      children: [
        {
          ident: "group-author--contributions--conceptualization",
          value_type: "boolean",
          text: "Conceptualization"
        },
        {
          ident: "group-author--contributions--investigation",
          value_type: "boolean",
          text: "Investigation"
        },
        {
          ident: "group-author--contributions--visualization",
          value_type: "boolean",
          text: "Visualization"
        },
        {
          ident: "group-author--contributions--methodology",
          value_type: "boolean",
          text: "Methodology"
        },
        {
          ident: "group-author--contributions--resources",
          value_type: "boolean",
          text: "Resources"
        },
        {
          ident: "group-author--contributions--supervision",
          value_type: "boolean",
          text: "Supervision"
        },
        {
          ident: "group-author--contributions--software",
          value_type: "boolean",
          text: "Software"
        },
        {
          ident: "group-author--contributions--data-curation",
          value_type: "boolean",
          text: "Data Curation"
        },
        {
          ident: "group-author--contributions--project-administration",
          value_type: "boolean",
          text: "Project Administration"
        },
        {
          ident: "group-author--contributions--validation",
          value_type: "boolean",
          text: "Validation"
        },
        {
          ident: "group-author--contributions--writing-original-draft",
          value_type: "boolean",
          text: "Writing - Original Draft"
        },
        {
          ident: "group-author--contributions--writing-review-and-editing",
          value_type: "boolean",
          text: "Writing - Review and Editing"
        },
        {
          ident: "group-author--contributions--funding-acquisition",
          value_type: "boolean",
          text: "Funding Acquisition"
        },
        {
          ident: "group-author--contributions--formal-analysis",
          value_type: "boolean",
          text: "Formal Analysis"
        }
      ]
    }

    content << {
      ident: "group-author--government-employee",
      value_type: "boolean",
      text: "Is this group a United States Government agency, department or organization?"
    }

    CardSeeder.seed_card('GroupAuthor', content)
  end
end
