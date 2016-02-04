FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    old_role 'admin'
    phase
    paper

    trait :with_participant do
      participants { [FactoryGirl.create(:user)] }
    end

    trait :with_nested_question_answers do
      nested_question_answers { FactoryGirl.create_list(:nested_question_answer, 3) }
    end
  end

  factory :assign_team_task, class: 'Tahi::AssignTeam::AssignTeamTask' do
    phase
    paper
    title "Assign Team"
    old_role "admin"
  end

  factory :competing_interests_task, class: 'TahiStandardTasks::CompetingInterestsTask' do
    phase
    paper
    title "Competing Interests"
    old_role "author"
  end

  factory :data_availability_task, class: 'TahiStandardTasks::DataAvailabilityTask' do
    phase
    paper
    title "Data Availability"
    old_role "author"
  end

  factory :ethics_task, class: 'TahiStandardTasks::EthicsTask' do
    phase
    paper
    title "Ethics"
    old_role "author"
  end

  factory :figure_task, class: 'TahiStandardTasks::FigureTask' do
    phase
    paper
    title "Figures"
    old_role "author"
  end

  factory :financial_disclosure_task, class: 'TahiStandardTasks::FinancialDisclosureTask' do
    phase
    paper
    title "Financial Disclosure"
    old_role "author"
  end

  factory :paper_admin_task, class: 'TahiStandardTasks::PaperAdminTask' do
    phase
    paper
    title "Assign Admin"
    old_role "admin"
  end

  factory :paper_editor_task, class: 'TahiStandardTasks::PaperEditorTask' do
    phase
    paper
    title "Invite Editor"
    old_role "admin"
  end

  factory :publishing_related_questions_task, class: 'TahiStandardTasks::PublishingRelatedQuestionsTask' do
    phase
    paper
    title 'Additional Information'
    old_role 'author'
  end

  factory :reporting_guidelines_task, class: 'TahiStandardTasks::ReportingGuidelinesTask' do
    phase
    paper
    title "Reporting Guidelines"
    old_role "author"
  end

  factory :taxon_task, class: 'TahiStandardTasks::TaxonTask' do
    phase
    paper
    title "Taxon"
    old_role "author"
  end

  factory :initial_tech_check_task, class: 'PlosBioTechCheck::InitialTechCheckTask' do
    phase
    paper
    title 'Initial Tech Check'
    old_role 'admin'
  end

  factory :changes_for_author_task, class: 'PlosBioTechCheck::ChangesForAuthorTask' do
    phase
    paper
    title "Changes for Author"
    old_role "author"
    body initialTechCheckBody: 'Default changes for author body'
  end

  factory :editors_discussion_task, class: 'PlosBioInternalReview::EditorsDiscussionTask' do
    phase
    paper
    title "Editor Discussion"
    old_role "admin"
  end

  factory :invitable_task, class: 'InvitableTask' do
    phase
    paper
    title "Invitable Task"
    old_role "user"
  end

  factory :cover_letter_task, class: "TahiStandardTasks::CoverLetterTask" do
    phase
    paper
    title "Cover Letter"
    old_role "author"
  end

  factory :metadata_task, class: 'MockMetadataTask' do
    phase
    paper
    title "Metadata Task"
    old_role "author"
  end

  factory :billing_task, class: 'PlosBilling::BillingTask' do
    phase
    paper
    title "Billing"
    old_role "author"
  end

  factory :authors_task, class: 'TahiStandardTasks::AuthorsTask' do
    phase
    paper
    title "Authors"
    old_role "author"
  end

  factory :production_metadata_task, class: "TahiStandardTasks::ProductionMetadataTask" do
    phase
    paper
    title "Production Metadata"
    old_role "admin"
  end

  factory :reviewer_recommendation_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    phase
    paper
    title "Reviewer Candidates"
    old_role "author"
  end

  factory :send_to_apex_task, class: 'TahiStandardTasks::SendToApexTask' do
    phase
    paper
    title 'Send to Apex'
    old_role 'admin'
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
    'test old_role'
  end
end

class InvitableTasksPolicy < TasksPolicy; end
