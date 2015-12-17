namespace 'nested-questions:seed' do
  task author: :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: Author.name,
      ident: "author--published_as_corresponding_author",
      value_type: "boolean",
      text: "This person will be listed as the corresponding author on the published article",
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
          ident: "author--contributions--conceived_and_designed_experiments",
          value_type: "boolean",
          text: "Conceived and designed the experiments",
          position: 1
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--performed_the_experiments",
          value_type: "boolean",
          text: "Performed the experiments",
          position: 2
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--analyzed_data",
          value_type: "boolean",
          text: "Analyzed the data",
          position: 3
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--contributed_tools",
          value_type: "boolean",
          text: "Contributed reagents/materials/analysis tools",
          position: 4
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--contributed_writing",
          value_type: "boolean",
          text: "Contributed to the writing of the manuscript",
          position: 5
        },
        {
          owner_id: nil,
          owner_type: Author.name,
          ident: "author--contributions--other",
          value_type: "text",
          text: "Other",
          position: 6
        }
      ]
    }

    NestedQuestion.where(owner_type: Author.name).update_all_exactly!(questions)
  end
end
