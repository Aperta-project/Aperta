require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'funder': :environment do
    content = []
    content << {
      ident: "funder--had_influence",
      value_type: "boolean",
      text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
      children: [
        {
          ident: "funder--had_influence--role_description",
          value_type: "text",
          text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript."
        }
      ]
    }

    CardSeeder.seed_card('TahiStandardTasks::Funder', content)
  end
end
