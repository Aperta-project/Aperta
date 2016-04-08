namespace 'nested-questions:seed' do
  task 'production-metadata-task': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--publication_date",
      value_type: "text",
      text: "Publication Date",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--volume_number",
      value_type: "text",
      text: "Volume Number",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--issue_number",
      value_type: "text",
      text: "Issue Number",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--provenance",
      value_type: "text",
      text: "Provenance",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--production_notes",
      value_type: "text",
      text: "Production Notes",
      position: 4
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--special_handling_instructions",
      value_type: "text",
      text: "Special Handling Instructions",
      position: 5
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::ProductionMetadataTask.name
    ).update_all_exactly!(questions)
  end
end
