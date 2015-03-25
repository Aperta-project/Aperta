FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    role 'admin'
    phase

    trait :with_participant do
      participants { [FactoryGirl.create(:user)] }
    end
  end

  factory :competing_interests_task, class: 'TahiStandardTasks::CompetingInterestsTask' do
    phase
    title "Competing Interests"
    role "author"
  end

  factory :data_availability_task, class: 'TahiStandardTasks::DataAvailabilityTask' do
    phase
    title "Data Availability"
    role "author"
  end

  factory :ethics_task, class: 'TahiStandardTasks::EthicsTask' do
    phase
    title "Ethics"
    role "author"
  end

  factory :figure_task, class: 'TahiStandardTasks::FigureTask' do
    phase
    title "Upload Figures"
    role "author"
  end

  factory :financial_disclosure_task, class: 'TahiStandardTasks::FinancialDisclosureTask' do
    phase
    title "Financial Disclosure"
    role "author"
  end

  factory :paper_admin_task, class: 'TahiStandardTasks::PaperAdminTask' do
    phase
    title "Assign Admin"
    role "admin"
  end

  factory :paper_editor_task, class: 'TahiStandardTasks::PaperEditorTask' do
    phase
    title "Assign Editor"
    role "admin"
  end

  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    phase
    title "Invite Reviewers"
    role "editor"
  end

  factory :publishing_related_questions_task, class: 'TahiStandardTasks::PublishingRelatedQuestionsTask' do
    phase
    title "Publishing Related Questions"
    role "author"
  end

  factory :register_decision_task, class: 'TahiStandardTasks::RegisterDecisionTask' do
    phase
    title "Register Decision"
    role "editor"
  end

  factory :reporting_guidelines_task, class: 'TahiStandardTasks::ReportingGuidelinesTask' do
    phase
    title "Reporting Guidelines"
    role "author"
  end

  factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
    phase
    title "Reviewer Report"
    role "reviewer"
  end

  factory :taxon_task, class: 'TahiStandardTasks::TaxonTask' do
    phase
    title "Taxon"
    role "author"
  end

  factory :tech_check_task, class: 'TahiStandardTasks::TechCheckTask' do
    phase
    title "Tech Check"
    role "admin"
  end
end
