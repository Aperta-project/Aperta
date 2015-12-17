namespace 'nested-questions:seed' do
  task 'reporting-guidelines-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: 'reporting_guidelines--clinical_trial',
      value_type: 'boolean',
      text: 'Clinical Trial',
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "reporting_guidelines--systematic_reviews",
      value_type: "boolean",
      text: "Systematic Reviews",
      position: 2,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
          ident: "reporting_guidelines--systematic_reviews--checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "reporting_guidelines--meta_analyses",
      value_type: "boolean",
      text: "Meta-analyses",
      position: 3,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
          ident: "reporting_guidelines--meta_analyses--checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "reporting_guidelines--diagnostic_studies",
      value_type: "boolean",
      text: "Diagnostic studies",
      position: 4
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "reporting_guidelines--epidemiological_studies",
      value_type: "boolean",
      text: "Epidemiological studies",
      position: 5
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name,
      ident: "reporting_guidelines--microarray_studies",
      value_type: "boolean",
      text: "Microarray studies",
      position: 6
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::ReportingGuidelinesTask.name
    ).update_all_exactly!(questions)
  end
end
