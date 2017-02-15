require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'production_metadata_task': :environment do
    content = []

    content << {
      ident: "production_metadata--publication_date",
      value_type: "text",
      text: "Publication Date"
    }

    content << {
      ident: "production_metadata--volume_number",
      value_type: "text",
      text: "Volume Number"
    }

    content << {
      ident: "production_metadata--issue_number",
      value_type: "text",
      text: "Issue Number"
    }

    content << {
      ident: "production_metadata--provenance",
      value_type: "text",
      text: "Provenance"
    }

    content << {
      ident: "production_metadata--production_notes",
      value_type: "text",
      text: "Production Notes"
    }

    content << {
      ident: "production_metadata--special_handling_instructions",
      value_type: "text",
      text: "Special Handling Instructions"
    }

    CardSeeder.seed_card('TahiStandardTasks::ProductionMetadataTask', content)
  end
end
