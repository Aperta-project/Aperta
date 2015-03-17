FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    role 'admin'
    phase

    trait :with_participant do
      participants { [FactoryGirl.create(:user)] }
    end
  end

  factory :competing_interests_task, class: 'StandardTasks::CompetingInterestsTask' do
    phase
    title "Competing Interests"
    role "author"
  end

  factory :data_availability_task, class: 'StandardTasks::DataAvailabilityTask' do
    phase
    title "Data Availability"
    role "author"
  end

  factory :ethics_task, class: 'StandardTasks::EthicsTask' do
    phase
    title "Ethics"
    role "author"
  end

  factory :figure_task, class: 'StandardTasks::FigureTask' do
    phase
    title "Upload Figures"
    role "author"
  end

  factory :financial_disclosure_task, class: 'StandardTasks::FinancialDisclosureTask' do
    phase
    title "Financial Disclosure"
    role "author"
  end

  factory :paper_admin_task, class: 'StandardTasks::PaperAdminTask' do
    phase
    title "Assign Admin"
    role "admin"
  end

  factory :paper_editor_task, class: 'StandardTasks::PaperEditorTask' do
    phase
    title "Assign Editor"
    role "admin"
  end

  factory :paper_reviewer_task, class: 'StandardTasks::PaperReviewerTask' do
    phase
    title "Invite Reviewers"
    role "editor"
  end

  factory :publishing_related_questions_task, class: 'StandardTasks::PublishingRelatedQuestionsTask' do
    phase
    title "Publishing Related Questions"
    role "author"
  end

  factory :register_decision_task, class: 'StandardTasks::RegisterDecisionTask' do
    phase
    title "Register Decision"
    role "editor"
  end

  factory :reporting_guidelines_task, class: 'StandardTasks::ReportingGuidelinesTask' do
    phase
    title "Reporting Guidelines"
    role "author"
  end

  factory :reviewer_report_task, class: 'StandardTasks::ReviewerReportTask' do
    phase
    title "Reviewer Report"
    role "reviewer"
  end

  factory :taxon_task, class: 'StandardTasks::TaxonTask' do
    phase
    title "Taxon"
    role "author"
  end

  factory :tech_check_task, class: 'StandardTasks::TechCheckTask' do
    phase
    title "Tech Check"
    role "admin"
  end
end
