FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    phase
    title "Reviewer Report"
    role "reviewer"
  end
end
