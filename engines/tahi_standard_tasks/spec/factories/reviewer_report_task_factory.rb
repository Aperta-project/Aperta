FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    association :paper, factory: [ :paper, :submitted_lite ]
    phase
    title "Reviewer Report"
  end

  factory :front_matter_reviewer_report_task, class: 'TahiStandardTasks::FrontMatterReviewerReportTask' do
    association :paper, factory: [ :paper, :submitted_lite ]
    phase
    title "Front Matter Reviewer Report"
  end
end
