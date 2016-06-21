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
      value_type: "boolean",
      text: "Do you have any potential or perceived competing interests that may influence your review?",
      position: 2,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--competing_interests--detail",
          value_type: "text",
          text: "Comment",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--comments_for_author",
      value_type: "text",
      text: "Add your comments to authors below.",
      position: 4
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--additional_comments",
      value_type: "text",
      text: "(Optional) If you have any additional confidential comments to the editor, please add them below.",
      position: 5
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--suitable_for_another_journal",
      value_type: "boolean",
      text: "If the manuscript does not meet the standards of PLOS Biology, do you think it is suitable for another PLOS journal?",
      position: 6,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--suitable_for_another_journal--journal",
          value_type: "text",
          text: "Other Journal",
          position: 1
        }
      ]
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::ReviewerReportTask.name
    ).update_all_exactly!(questions)
  end
end
