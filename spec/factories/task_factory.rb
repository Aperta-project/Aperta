FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    role 'admin'
    phase

    trait :with_participant do
      participants { [FactoryGirl.create(:user)] }
    end

    trait :with_questions do
      questions { FactoryGirl.create_list(:question, 3) }
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
    title "Figures"
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
    title "Invite Editor"
    role "admin"
  end

  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    phase
    title "Invite Reviewers"
    role "reviewer"
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

  factory :initial_tech_check_task, class: 'PlosBioTechCheck::InitialTechCheckTask' do
    phase
    title 'Initial Tech Check'
    role 'admin'
  end

  factory :changes_for_author_task, class: 'PlosBioTechCheck::ChangesForAuthorTask' do
    phase
    title "Changes for Author"
    role "author"
    body initialTechCheckBody: 'Default changes for author body'
  end

  factory :editors_discussion_task, class: 'PlosBioInternalReview::EditorsDiscussionTask' do
    phase
    title "Editor Discussion"
    role "admin"
  end

  factory :invitable_task, class: 'InvitableTask' do
    phase
    title "Invitable Task"
    role "user"
  end

  factory :cover_letter_task, class: "TahiStandardTasks::CoverLetterTask" do
    phase
    title "Cover Letter"
    role "author"
  end

  factory :metadata_task, class: "MockMetadataTask" do
    phase
    title "Metadata Task"
    role "author"
  end
end

class MockMetadataTask < Task
  include MetadataTask
end
class MetadataTaskPolicy < TasksPolicy; end

class InvitableTask < Task
  include TaskTypeRegistration
  include Invitable

  register_task default_title: "Test Task", default_role: "user"

  def invitation_invited(_invitation)
    :invited
  end

  def invitation_accepted(_invitation)
    :accepted
  end

  def invitation_rejected(_invitation)
    :rejected
  end

  def invitation_rescinded(invitation)
    :rescinded
  end

  def active_model_serializer
    ::TaskSerializer
  end

  def invitee_role
    'test role'
  end
end

class InvitableTasksPolicy < TasksPolicy; end
