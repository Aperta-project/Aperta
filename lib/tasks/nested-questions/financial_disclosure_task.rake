namespace 'nested-questions:seed' do
  task 'financial-disclosure-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FinancialDisclosureTask.name,
      ident: "financial_disclosures--author_received_funding",
      value_type: "boolean",
      text: "Did any of the authors receive specific funding for this work?",
      position: 1
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::FinancialDisclosureTask.name
    ).update_all_exactly!(questions)
  end
end
