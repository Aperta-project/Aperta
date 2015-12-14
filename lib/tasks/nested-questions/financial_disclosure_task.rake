namespace 'nested-questions:seed' do
  task 'financial-disclosure-task': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::FinancialDisclosureTask.name,
      ident: "financial_disclosures.author_received_funding",
      value_type: "boolean",
      text: "Did any of the authors receive specific funding for this work?",
      position: 1
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::FinancialDisclosureTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
