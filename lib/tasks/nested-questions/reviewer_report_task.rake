namespace 'nested-questions:seed' do
  task 'reviewer-report-task': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: 'reviewer_report--decision_term',
      value_type: 'text',
      text: 'Please provide your publication recommendation:',
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--competing_interests",
      value_type: "text",
      text: "Do you have any potential or perceived competing interests that may influence your review?",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--plos_biology_suitable",
      value_type: "boolean",
      text: "Is this manuscript suitable in principle for PLOS Biology? Comments for authors.",
      position: 3,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--plos_biology_suitable--comment",
          value_type: "text",
          text: "Comment",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--statistical_analysis",
      value_type: "boolean",
      text: "Has the statistical analysis been performed appropriately and rigorously?",
      position: 4,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--statistical_analysis--explanation",
          value_type: "text",
          text: "Statistical Analysis Explanation",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--standards",
      value_type: "boolean",
      text: "Does the manuscript adhere to standards in this field for data availability?",
      position: 5,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--standards--explanation",
          value_type: "text",
          text: "Standards Explanation",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--additional_comments",
      value_type: "text",
      text: "(Optional) Please offer any additional confidential comments to the editor",
      position: 6
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
      position: 7
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::ReviewerReportTask.name
    ).update_all_exactly!(questions)
  end
end
