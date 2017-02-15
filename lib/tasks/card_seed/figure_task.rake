require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'figure_task': :environment do
    content = []
    content << {
      ident: "figures--complies",
      value_type: "boolean",
      text: "Yes - I confirm our figures comply with the guidelines."
    }

    CardSeeder.seed_card('TahiStandardTasks::FigureTask', content)
  end
end
