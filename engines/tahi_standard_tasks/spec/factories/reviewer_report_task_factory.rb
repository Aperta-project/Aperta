FactoryGirl.define do
  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    paper
    phase
    title "Reviewer Report"
    old_role "reviewer"
    uses_research_article_reviewer_report true
  end

  factory :front_matter_reviewer_report_task, class: 'TahiStandardTasks::FrontMatterReviewerReportTask' do
    paper
    phase
    title "Front Matter Reviewer Report"
    old_role "reviewer"
  end
end
