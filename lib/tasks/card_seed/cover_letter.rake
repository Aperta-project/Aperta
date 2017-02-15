require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'cover_letter_task': :environment do
    content = []
    content << {
      ident: "cover_letter--text",
      value_type: "text",
    }
    content << {
      ident: "cover_letter--attachment",
      value_type: "attachment",
    }

    CardSeeder.seed_card('TahiStandardTasks::CoverLetterTask', content)
  end
end
