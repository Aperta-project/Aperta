require_relative './support/card_seeder'
namespace 'card_seed' do
  task author: :environment do
    content = []

    content << {
      ident: "author--published_as_corresponding_author",
      value_type: "boolean",
      text: "This person should be identified as corresponding author on the published article"
    }

    content << {
      ident: "author--deceased",
      value_type: "boolean",
      text: "This person is deceased"
    }

    content << {
      ident: "author--contributions",
      value_type: "question-set",
      text: "Author Contributions",
      children: [
        {
          ident: "author--contributions--conceptualization",
          value_type: "boolean",
          text: "Conceptualization"
        },
        {
          ident: "author--contributions--investigation",
          value_type: "boolean",
          text: "Investigation"
        },
        {
          ident: "author--contributions--visualization",
          value_type: "boolean",
          text: "Visualization"
        },
        {
          ident: "author--contributions--methodology",
          value_type: "boolean",
          text: "Methodology"
        },
        {
          ident: "author--contributions--resources",
          value_type: "boolean",
          text: "Resources"
        },
        {
          ident: "author--contributions--supervision",
          value_type: "boolean",
          text: "Supervision"
        },
        {
          ident: "author--contributions--software",
          value_type: "boolean",
          text: "Software"
        },
        {
          ident: "author--contributions--data-curation",
          value_type: "boolean",
          text: "Data Curation"
        },
        {
          ident: "author--contributions--project-administration",
          value_type: "boolean",
          text: "Project Administration"
        },
        {
          ident: "author--contributions--validation",
          value_type: "boolean",
          text: "Validation"
        },
        {
          ident: "author--contributions--writing-original-draft",
          value_type: "boolean",
          text: "Writing - Original Draft"
        },
        {
          ident: "author--contributions--writing-review-and-editing",
          value_type: "boolean",
          text: "Writing - Review and Editing"
        },
        {
          ident: "author--contributions--funding-acquisition",
          value_type: "boolean",
          text: "Funding Acquisition"
        },
        {
          ident: "author--contributions--formal-analysis",
          value_type: "boolean",
          text: "Formal Analysis"
        }
      ]
    }

    content << {
      ident: "author--government-employee",
      value_type: "boolean",
      text: "Is this author an employee of the United States Government?"
    }

    CardSeeder.seed_card('Author', content)
  end
end
