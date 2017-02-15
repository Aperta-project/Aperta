require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'early_posting_task': :environment do
    content = []
    content << {
      ident: "early-posting--consent",
      value_type: "boolean",
      text: "Yes, I agree to publish an early version of my article"
    }

    CardSeeder.seed_card('TahiStandardTasks::EarlyPostingTask', content)
  end
end
