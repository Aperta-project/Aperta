require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'financial_disclosure_task': :environment do
    content = []
    content << {
      ident: "financial_disclosures--author_received_funding",
      value_type: "boolean",
      text: "Did any of the authors receive specific funding for this work?",
    }

    CardSeeder.seed_card('TahiStandardTasks::FinancialDisclosureTask', content)
  end
end
