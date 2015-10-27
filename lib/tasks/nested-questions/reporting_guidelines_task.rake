namespace 'nested-questions:seed' do
  task 'reporting-guidelines-task': :environment do
    questions = []
    questions << NestedQuestion.new(owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "clinical_trial",
      value_type: "boolean",
      text: "Clinical Trial", position: 1)

    questions <<  NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "systematic_reviews",
      value_type: "boolean",
      text: "Systematic Reviews",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
          ident: "checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "meta_analyses",
      value_type: "boolean",
      text: "Meta-analyses",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
          ident: "checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "diagnostic_studies",
      value_type: "boolean",
      text: "Diagnostic studies",
      position: 4)
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "epidemiological_studies",
      value_type: "boolean",
      text: "Epidemiological studies",
      position: 5)
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "microarray_studies",
      value_type: "boolean",
      text: "Microarray studies",
      position: 6)

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::ReportingGuidelinesTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
