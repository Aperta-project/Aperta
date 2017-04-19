FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    association :paper, factory: [ :paper, :submitted_lite ]
    phase
    card_version
    title "Reviewer Report"
  end

  factory :front_matter_reviewer_report_task, class: 'TahiStandardTasks::FrontMatterReviewerReportTask' do
    association :paper, factory: [ :paper, :submitted_lite ]
    phase
    card_version
    title "Front Matter Reviewer Report"
  end
end
