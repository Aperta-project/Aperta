FactoryGirl.define do
  # This trait is building a task but using FactoryGirl stubs for associations
  # it normally depends on. This reduces the time it takes to construct the
  # task.
  trait :with_stubbed_associations do
    paper { FactoryGirl.build_stubbed(:paper) }
    phase { FactoryGirl.build_stubbed(:phase) }
  end

  trait :with_card do
    after(:create) do |task|
      # first check to see if there's an existing card we can use
      name = task.class.to_s
      Card.find_by(name: name) || FactoryGirl.create(:card, :versioned, name: name)
    end
  end
  factory :ad_hoc_task do
    title "Do something awesome"
    phase
    paper
  end

  factory :assign_team_task, class: 'Tahi::AssignTeam::AssignTeamTask' do
    phase
    paper
    title "Assign Team"
  end

  factory :cover_letter_task, class: 'TahiStandardTasks::CoverLetterTask' do
    phase
    paper
    title "Cover Letter"
  end

  factory :competing_interests_task, class: 'TahiStandardTasks::CompetingInterestsTask' do
    phase
    paper
    title "Competing Interests"
  end

  factory :data_availability_task, class: 'TahiStandardTasks::DataAvailabilityTask' do
    phase
    paper
    title "Data Availability"
  end

  factory :early_posting_task, class: 'TahiStandardTasks::EarlyPostingTask' do
    phase
    paper
    title "Early Article Posting"

    before(:create) do
      early_posting = CardContent.find_by_ident('early-posting--consent')
      FactoryGirl.create(:card_content, ident: 'early-posting--consent').save unless early_posting
    end
  end

  factory :ethics_task, class: 'TahiStandardTasks::EthicsTask' do
    phase
    paper
    title "Ethics"
  end

  factory :figure_task, class: 'TahiStandardTasks::FigureTask' do
    phase
    paper
    title "Figures"
  end

  factory :financial_disclosure_task, class: 'TahiStandardTasks::FinancialDisclosureTask' do
    phase
    paper
    title "Financial Disclosure"
  end

  factory :paper_editor_task, class: 'TahiStandardTasks::PaperEditorTask' do
    phase
    paper
    title "Invite Editor"
  end

  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    paper
    phase
    title 'Invite Reviewers'
  end

  factory :publishing_related_questions_task, class: 'TahiStandardTasks::PublishingRelatedQuestionsTask' do
    phase
    paper
    title 'Additional Information'
  end

  factory :reporting_guidelines_task, class: 'TahiStandardTasks::ReportingGuidelinesTask' do
    phase
    paper
    title "Reporting Guidelines"
  end

  factory :related_articles_task, class: 'TahiStandardTasks::RelatedArticlesTask' do
    phase
    paper
    title "Related Articles"
  end

  factory :taxon_task, class: 'TahiStandardTasks::TaxonTask' do
    phase
    paper
    title "Taxon"
  end

  factory :initial_tech_check_task, class: 'PlosBioTechCheck::InitialTechCheckTask' do
    phase
    paper
    title 'Initial Tech Check'
  end

  factory :final_tech_check_task, class: 'PlosBioTechCheck::FinalTechCheckTask' do
    phase
    paper
    title 'Final Tech Check'
  end

  factory :revision_tech_check_task, class: 'PlosBioTechCheck::RevisionTechCheckTask' do
    phase
    paper
    title 'Revision Tech Check'
  end

  factory :changes_for_author_task, class: 'PlosBioTechCheck::ChangesForAuthorTask' do
    phase
    paper
    title "Changes for Author"
    body initialTechCheckBody: 'Default changes for author body'
  end

  factory :editors_discussion_task, class: 'PlosBioInternalReview::EditorsDiscussionTask' do
    phase
    paper
    title "Editor Discussion"
  end

  factory :invitable_task, class: 'InvitableTestTask' do
    phase
    paper { FactoryGirl.create(:paper, :submitted_lite) }
    title "Invitable Task"
  end

  factory :metadata_task, class: 'MetadataTestTask' do
    phase
    paper
    title "Metadata Task"
  end

  factory :billing_task, class: 'PlosBilling::BillingTask' do
    phase
    paper
    title "Billing"
    trait :with_card_content do
      after(:create) do |task|
        task.card.content_for_version_without_root(:latest).each do |card_content|
          value = "#{card_content.ident} answer"
          value = 'bob@example.com' if card_content.ident == 'plos_billing--email'
          task.find_or_build_answer_for(card_content: card_content, value: value)
        end
      end
    end
  end

  factory :authors_task, class: 'TahiStandardTasks::AuthorsTask' do
    phase
    paper
    title "Authors"
  end

  factory :production_metadata_task, class: "TahiStandardTasks::ProductionMetadataTask" do
    phase
    paper
    title "Production Metadata"
  end

  factory :reviewer_recommendation_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    phase
    paper
    title "Reviewer Candidates"
  end

  factory :send_to_apex_task, class: 'TahiStandardTasks::SendToApexTask' do
    phase
    paper
    title 'Send to Apex'
  end

  factory :title_and_abstract_task, class: 'TahiStandardTasks::TitleAndAbstractTask' do
    phase
    paper
    title 'Title and Abstract'
  end
end

class MetadataTestTask < Task
  include MetadataTask

  DEFAULT_TITLE = 'Mock Metadata Task'.freeze
end

class InvitableTestTask < Task
  include Invitable

  DEFAULT_TITLE = 'Test Task'.freeze
  DEFAULT_ROLE_HINT = 'user'.freeze

  def invitation_invited(_invitation)
    :invited
  end

  def invitation_accepted(_invitation)
    :accepted
  end

  def invitation_declined(_invitation)
    :declined
  end

  def invitation_rescinded(_invitation)
    :rescinded
  end

  def active_model_serializer
    ::TaskSerializer
  end

  def invitee_role
    'test role'
  end
end
