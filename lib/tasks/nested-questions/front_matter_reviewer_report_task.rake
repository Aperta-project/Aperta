namespace 'nested-questions:seed' do
  task 'front-matter-reviewer-report-task': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: 'front_matter_reviewer_report--decision_term',
      value_type: 'text',
      text: 'Please provide your publication recommendation:',
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: "front_matter_reviewer_report--competing_interests",
      value_type: "text",
      text: "Do you have any potential or perceived competing interests that may influence your review?",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: "front_matter_reviewer_report--suitable",
      value_type: "boolean",
      text: "Is this manuscript suitable in principle for <em>PLOS Biology</em>? Comments for authors.",
      position: 3,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
          ident: "front_matter_reviewer_report--suitable--comment",
          value_type: "text",
          text: "Suitable Comment",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: "front_matter_reviewer_report--includes_unpublished_data",
      value_type: "boolean",
      text: "If previously unpublished data are included to support the conclusions, please note in the box below whether:",
      position: 4,
      children: [
        {
          owner_id: nil,
          owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
          ident: "front_matter_reviewer_report--includes_unpublished_data--explanation",
          value_type: "text",
          text: "Includes Published Data Explanation",
          position: 1
        }
      ]
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: "front_matter_reviewer_report--additional_comments",
      value_type: "text",
      text: "(Optional) Please offer any additional confidential comments to the editor",
      position: 5
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name,
      ident: "front_matter_reviewer_report--identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
      position: 6
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::FrontMatterReviewerReportTask.name
    ).update_all_exactly!(questions)
  end
end
