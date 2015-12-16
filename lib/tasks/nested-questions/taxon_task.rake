namespace 'nested-questions:seed' do
  task 'taxon-task': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::TaxonTask.name,
      ident: "taxon--zoological",
      value_type: "boolean",
      text: "Does this manuscript describe a new zoological taxon name?",
      position: 1,
      children: [
        NestedQuestion.new(owner_id:nil,
          owner_type: TahiStandardTasks::TaxonTask.name,
          ident: "taxon--zoological--complies",
          value_type: "boolean",
          text: "All authors comply with the Policies Regarding Submission of a new Taxon Name",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TahiStandardTasks::TaxonTask.name,
      ident: "taxon--botanical",
      value_type: "boolean",
      text: "Does this manuscript describe a new botantical taxon name?",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TahiStandardTasks::TaxonTask.name,
          ident: "taxon--botanical--complies",
          value_type: "boolean",
          text: "All authors comply with the Policies Regarding Submission of a new Taxon Name",
          position: 1
        )
      ]
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::TaxonTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
