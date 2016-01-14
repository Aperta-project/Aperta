FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    paper
    phase
    title "Reviewer Report"
    old_role "reviewer"
  end
end
