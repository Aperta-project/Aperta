namespace 'nested-questions:seed' do
  task 'production-metadata-task': :environment do
    questions = []

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--publication_date",
      value_type: "text",
      text: "Publication Date",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--volume_number",
      value_type: "text",
      text: "Volume Number",
      position: 2
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--issue_number",
      value_type: "text",
      text: "Issue Number",
      position: 3
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ProductionMetadataTask.name,
      ident: "production_metadata--production_notes",
      value_type: "text",
      text: "Production Notes",
      position: 4
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::ProductionMetadataTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
