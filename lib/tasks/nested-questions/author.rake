namespace 'nested-questions:seed' do
  task author: :environment do
    questions = []

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: Author.name,
      ident: "published_as_corresponding_author",
      value_type: "boolean",
      text: "This person will be listed as the corresponding author on the published article",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: Author.name,
      ident: "deceased",
      value_type: "boolean",
      text: "This person is deceased",
      position: 2
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: Author.name,
      ident: "contributions",
      value_type: "question-set",
      text: "Author Contributions",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "conceived_and_designed_experiments",
          value_type: "boolean",
          text: "Conceived and designed the experiments",
          position: 1
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "performed_the_experiments",
          value_type: "boolean",
          text: "Performed the experiments",
          position: 2
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "analyzed_data",
          value_type: "boolean",
          text: "Analyzed the data",
          position: 3
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "contributed_tools",
          value_type: "boolean",
          text: "Contributed reagents/materials/analysis tools",
          position: 4
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "contributed_writing",
          value_type: "boolean",
          text: "Contributed to the writing of the manuscript",
          position: 5
        ),
        NestedQuestion.new(
          owner_id: nil,
          owner_type: Author.name,
          ident: "other",
          value_type: "text",
          text: "Other",
          position: 6
        )
      ]
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:Author.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
