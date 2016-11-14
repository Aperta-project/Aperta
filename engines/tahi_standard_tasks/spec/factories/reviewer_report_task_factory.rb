FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    paper
    phase
    title "Reviewer Report"
  end

  factory :front_matter_reviewer_report_task, class: 'TahiStandardTasks::FrontMatterReviewerReportTask' do
    paper
    phase
    title "Front Matter Reviewer Report"
  end
end
