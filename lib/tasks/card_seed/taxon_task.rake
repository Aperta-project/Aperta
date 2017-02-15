require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'taxon_task': :environment do
    content = []
    content << {
      ident: "taxon--zoological",
      value_type: "boolean",
      text: "Does this manuscript describe a new zoological taxon name?",
      children: [
        {
          ident: "taxon--zoological--complies",
          value_type: "boolean",
          text: "All authors comply with the Policies Regarding Submission of a new Taxon Name"
        }
      ]
    }

    content << {
      ident: "taxon--botanical",
      value_type: "boolean",
      text: "Does this manuscript describe a new botanical taxon name?",
      children: [
        {
          ident: "taxon--botanical--complies",
          value_type: "boolean",
          text: "All authors comply with the Policies Regarding Submission of a new Taxon Name"
        }
      ]
    }

    CardSeeder.seed_card('TahiStandardTasks::TaxonTask', content)
  end
end
