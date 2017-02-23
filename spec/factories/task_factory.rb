FactoryGirl.define do
  # This trait is building a task but using FactoryGirl stubs for associations
  # it normally depends on. This reduces the time it takes to construct the
  # task.
  trait :with_stubbed_associations do
    paper { FactoryGirl.build_stubbed(:paper) }
    phase { FactoryGirl.build_stubbed(:phase) }
  end

  trait :with_card do
    after(:build) do |answerable|
      answerable.card = Card.find_by(name: answerable.class.name)
    end
  end

  factory :task do
    phase
    paper
    after(:build) do |answerable|
      answerable.card = Card.find_by(name: answerable.class.name)
    end

    factory :cover_letter_task, class: 'TahiStandardTasks::CoverLetterTask' do
      title "Cover Letter"
    end

    factory :ad_hoc_task do
      title "Do something awesome"

      trait :with_nested_question_answers do
        nested_question_answers { FactoryGirl.create_list(:nested_question_answer, 3) }
      end
    end

    factory :assign_team_task, class: 'Tahi::AssignTeam::AssignTeamTask' do
      title "Assign Team"
    end

    factory :competing_interests_task, class: 'TahiStandardTasks::CompetingInterestsTask' do
      title "Competing Interests"
    end

    factory :data_availability_task, class: 'TahiStandardTasks::DataAvailabilityTask' do
      title "Data Availability"
    end

    factory :early_posting_task, class: 'TahiStandardTasks::EarlyPostingTask' do
      title "Early Article Posting"

      before(:create) do
        early_posting = NestedQuestion.find_by_ident('early-posting--consent')
        FactoryGirl.create(:nested_question, ident: 'early-posting--consent').save unless early_posting
      end
    end

    factory :ethics_task, class: 'TahiStandardTasks::EthicsTask' do
      title "Ethics"
    end

    factory :figure_task, class: 'TahiStandardTasks::FigureTask' do
      title "Figures"
    end

    factory :financial_disclosure_task, class: 'TahiStandardTasks::FinancialDisclosureTask' do
      title "Financial Disclosure"
    end

    factory :initial_decision_task, class: 'TahiStandardTasks::InitialDecisionTask' do
      title "Initial Decision"
    end

    factory :paper_editor_task, class: 'TahiStandardTasks::PaperEditorTask' do
      title "Invite Editor"
    end

    factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
      title 'Invite Reviewers'
    end

    factory :publishing_related_questions_task, class: 'TahiStandardTasks::PublishingRelatedQuestionsTask' do
      title 'Additional Information'
    end

    factory :register_decision_task, class: 'TahiStandardTasks::RegisterDecisionTask' do
      title "Register Decision"
    end

    factory :reporting_guidelines_task, class: 'TahiStandardTasks::ReportingGuidelinesTask' do
      title "Reporting Guidelines"
    end

    factory :related_articles_task, class: 'TahiStandardTasks::RelatedArticlesTask' do
      title "Related Articles"
    end

    factory :reviewer_recommendations_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
      title "Reviewer Candidates"
    end

    factory :reviewer_report_task, class: 'TahiStandardTasks::ReviewerReportTask' do
      association :paper, factory: [ :paper, :submitted_lite ]
      title "Reviewer Report"
    end

    factory :front_matter_reviewer_report_task, class: 'TahiStandardTasks::FrontMatterReviewerReportTask' do
      association :paper, factory: [ :paper, :submitted_lite ]
      title "Front Matter Reviewer Report"
    end

    factory :taxon_task, class: 'TahiStandardTasks::TaxonTask' do
      title "Taxon"
    end

    factory :supporting_information_task, class: 'TahiStandardTasks::SupportingInformationTask' do
      title "Supporting Information"
    end

    factory :initial_tech_check_task, class: 'PlosBioTechCheck::InitialTechCheckTask' do
      title 'Initial Tech Check'
    end

    factory :final_tech_check_task, class: 'PlosBioTechCheck::FinalTechCheckTask' do
      title 'Final Tech Check'
    end

    factory :revision_tech_check_task, class: 'PlosBioTechCheck::RevisionTechCheckTask' do
      title 'Revision Tech Check'
    end

    factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
      title "Revise Manusript"
    end

    factory :changes_for_author_task, class: 'PlosBioTechCheck::ChangesForAuthorTask' do
      title "Changes for Author"
      body initialTechCheckBody: 'Default changes for author body'
    end

    factory :upload_manuscript_task, class: 'TahiStandardTasks::UploadManuscriptTask' do
      title "Upload Manuscript"
    end

    factory :editors_discussion_task, class: 'PlosBioInternalReview::EditorsDiscussionTask' do
      title "Editor Discussion"
    end

    factory :invitable_task, class: 'InvitableTestTask' do
      paper { FactoryGirl.create(:paper, :submitted_lite) }
      title "Invitable Task"
    end

    factory :metadata_task, class: 'MetadataTestTask' do
      title "Metadata Task"
    end

    factory :billing_task, class: 'PlosBilling::BillingTask' do
      title "Billing"
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
      title "Authors"
    end

    factory :production_metadata_task, class: "TahiStandardTasks::ProductionMetadataTask" do
      title "Production Metadata"
    end

    factory :reviewer_recommendation_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
      title "Reviewer Candidates"
    end

    factory :send_to_apex_task, class: 'TahiStandardTasks::SendToApexTask' do
      title 'Send to Apex'
    end

    factory :title_and_abstract_task, class: 'TahiStandardTasks::TitleAndAbstractTask' do
      title 'Title and Abstract'
    end
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
