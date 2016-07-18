FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    old_role 'admin'
    phase
    paper

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

  factory :cover_letter_task, class: 'TahiStandardTasks::CoverLetterTask' do
    phase
    paper
    title "Cover Letter"
    old_role "author"
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

  factory :related_articles_task, class: 'TahiStandardTasks::RelatedArticlesTask' do
    phase
    paper
    title "Related Articles"
    old_role "editor"
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

  factory :final_tech_check_task, class: 'PlosBioTechCheck::FinalTechCheckTask' do
    phase
    paper
    title 'Final Tech Check'
    old_role 'admin'
  end

  factory :revision_tech_check_task, class: 'PlosBioTechCheck::RevisionTechCheckTask' do
    phase
    paper
    title 'Revision Tech Check'
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

  factory :invitable_task, class: 'InvitableTestTask' do
    phase
    paper { FactoryGirl.create(:paper, :submitted_lite) }
    title "Invitable Task"
    old_role "user"
  end

  factory :metadata_task, class: 'MetadataTestTask' do
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
    trait :with_nested_question_answers do
      after(:create) do |task|
        task.nested_questions.each do |nested_question|
          value = "#{nested_question.ident} answer"
          value = 'bob@example.com' if nested_question.ident == 'plos_billing--email'
          task.find_or_build_answer_for(nested_question: nested_question, value: value)
        end
      end
    end
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

  factory :title_and_abstract_task, class: 'TahiStandardTasks::TitleAndAbstractTask' do
    phase
    paper
    title 'Title and Abstract'
    old_role 'editor'
  end
end

class MetadataTestTask < Task
  include MetadataTask

  DEFAULT_TITLE = 'Mock Metadata Task'
end

class InvitableTestTask < Task
  include Invitable

  DEFAULT_TITLE = 'Test Task'
  DEFAULT_ROLE = 'user'

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
