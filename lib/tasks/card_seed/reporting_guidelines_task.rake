require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'reporting_guidelines_task': :environment do
    content = []
    content << {
      ident: 'reporting_guidelines--clinical_trial',
      value_type: 'boolean',
      text: 'Clinical Trial'
    }

    content << {
      ident: "reporting_guidelines--systematic_reviews",
      value_type: "boolean",
      text: "Systematic Reviews",
      children: [
        {
          ident: "reporting_guidelines--systematic_reviews--checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/' target='_blank'>download it here</a>."
        }
      ]
    }

    content << {
      ident: "reporting_guidelines--meta_analyses",
      value_type: "boolean",
      text: "Meta-analyses",
      children: [
        {
          ident: "reporting_guidelines--meta_analyses--checklist",
          value_type: "attachment",
          text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/' target='_blank'>download it here</a>."
        }
      ]
    }

    content << {
      ident: "reporting_guidelines--diagnostic_studies",
      value_type: "boolean",
      text: "Diagnostic studies"
    }
    content << {
      ident: "reporting_guidelines--epidemiological_studies",
      value_type: "boolean",
      text: "Epidemiological studies"
    }
    content << {
      ident: "reporting_guidelines--microarray_studies",
      value_type: "boolean",
      text: "Microarray studies"
    }

    CardSeeder.seed_card('TahiStandardTasks::ReportingGuidelinesTask', content)
  end
end
