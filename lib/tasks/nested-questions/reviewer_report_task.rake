namespace 'nested-questions:seed' do
  task 'reviewer-report-task': :environment do
    questions = []

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--competing_interests",
      value_type: "text",
      text: "Do you have any potential or perceived competing interests that may influence your review?",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--support_conclusions",
      value_type: "boolean",
      text: "Is the manuscript technically sound, and do the data support the conclusions?",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--support_conclusions--explanation",
          value_type: "text",
          text: "Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--statistical_analysis",
      value_type: "boolean",
      text: "Has the statistical analysis been performed appropriately and rigorously?",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--statistical_analysis--explanation",
          value_type: "text",
          text: "Statistical Analysis Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--standards",
      value_type: "boolean",
      text: "Does the manuscript adhere to standards in this field for data availability?",
      position: 4,
      children: [
        NestedQuestion.new(
          owner_id:nil,
          owner_type: TahiStandardTasks::ReviewerReportTask.name,
          ident: "reviewer_report--standards--explanation",
          value_type: "text",
          text: "Standards Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--additional_comments",
      value_type: "text",
      text: "(Optional) Please offer any additional comments to the author.",
      position: 5
    )

    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::ReviewerReportTask.name,
      ident: "reviewer_report--identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
      position: 6
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::ReviewerReportTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
