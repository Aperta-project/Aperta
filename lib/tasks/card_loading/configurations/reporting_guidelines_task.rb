# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ReportingGuidelinesTask
    def self.name
      "TahiStandardTasks::ReportingGuidelinesTask"
    end

    def self.title
      "Reporting Guidelines Task"
    end

    def self.content
      [
        {
          ident: 'reporting_guidelines--clinical_trial',
          value_type: 'boolean',
          text: 'Clinical Trial'
        },

        {
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
        },

        {
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
        },

        {
          ident: "reporting_guidelines--diagnostic_studies",
          value_type: "boolean",
          text: "Diagnostic studies"
        },
        {
          ident: "reporting_guidelines--epidemiological_studies",
          value_type: "boolean",
          text: "Epidemiological studies"
        },
        {
          ident: "reporting_guidelines--microarray_studies",
          value_type: "boolean",
          text: "Microarray studies"
        }
      ]
    end
  end
end
