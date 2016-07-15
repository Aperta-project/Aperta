require 'securerandom'

FactoryGirl.define do
  factory :paper do
    journal

    uses_research_article_reviewer_report true

    trait :with_integration_journal do
      association :journal, factory: :journal_with_roles_and_permissions
    end

    trait :with_creator do
      after(:create) do |paper|
        if paper.journal
          paper.journal.creator_role || paper.journal.create_creator_role!
        end

        unless paper.creator
          paper.update!(creator: FactoryGirl.create(:user))
        end

        paper.save!
        paper.body = "I am the very model of a modern journal article"
      end
    end

    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    trait(:active) do
      # noop
    end

    trait(:inactive) do
      after(:create, &:withdraw!)
    end

    trait(:checking) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
        paper.minor_check! paper.creator
      end
    end

    trait(:accepted) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
        paper.accept!
      end
    end

    # TODO: find all cases where this trait is used and change to trait of 'submitted'
    trait(:completed) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
      end
    end

    trait(:initially_submitted) do
      after(:create, &:initial_submit!)
    end

    trait(:submitted) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
      end
    end

    # TODO: get rid of this in favor of using :submitted. At the moment
    # :submitted requires a full R&P setup which makes it fail in most unit
    # tests. We should make the state transitions behave gracefully when R&P
    # config doesn't exist
    trait(:submitted_lite) do
      publishing_state :submitted
      after :create, &:new_draft_decision!
    end

    # TODO: reimplement this using actual AASM transitions. Like above.
    trait(:rejected_lite) do
      publishing_state :rejected
      after :create do |paper|
        paper.decisions.completed.create!(verdict: "reject")
      end
    end

    trait(:unsubmitted) do
      # noop
    end

    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.creator).add_phases_and_tasks
      end
    end

    trait(:with_short_title) do
      transient do
        short_title 'some title'
      end

      after(:create) do |paper, evaluator|
        task = FactoryGirl.create(
          :publishing_related_questions_task,
          paper: paper)
        nested_question = FactoryGirl.create(
          :nested_question,
          ident: 'publishing_related_questions--short_title')
        task.find_or_build_answer_for(nested_question: nested_question,
                                      value: evaluator.short_title).save
      end
    end

    trait(:with_author) do
      after(:create) do |paper|
        FactoryGirl.create(
          :author,
          paper: paper
        )
      end
    end

    %w(
      academic_editor creator collaborator cover_editor discussion_participant
      handling_editor internal_editor reviewer publishing_services staff_admin
      task_participant
    ).each do |role|
      trait("with_#{role}_user".to_sym) do
        after(:create) do |paper|
          begin
            FactoryGirl.create(
              :assignment,
              role: paper.journal.send("#{role}_role".to_sym),
              user: FactoryGirl.build(:user),
              assigned_to: paper
            )
          rescue Exception => ex
            STDERR.puts <<-ERROR.strip_heredoc
              Missing role #{role}!
              Do you want to add :with_#{role}_role to your journal?
            ERROR
            fail ex
          end
        end
      end
    end

    trait(:with_versions) do
      transient do
        first_version_body  'first body'
        second_version_body 'second body'
      end

      after(:create) do |paper, evaluator|
        paper.body = evaluator.first_version_body
        paper.save!

        paper.submit! paper.creator
        paper.major_revision!
        paper.body = evaluator.second_version_body
        paper.save!
      end
    end

    after(:build) do |paper|
      paper.paper_type ||= paper.journal.paper_types.first
    end

    after(:create) do |paper, evaluator|
      paper.body = evaluator.body
    end

    factory :paper_with_phases do
      transient do
        phases_count 1
      end

      after(:create) do |paper, evaluator|
        paper.phases << FactoryGirl.build_list(:phase, evaluator.phases_count)
      end
    end

    factory :paper_with_task do
      transient do
        task_params {}
      end

      after(:create) do |paper, evaluator|
        phase = create(:phase, paper: paper)
        evaluator.task_params[:title] ||= "Ad Hoc"
        evaluator.task_params[:old_role] ||= "user"
        evaluator.task_params[:type] ||= "Task"
        evaluator.task_params[:paper] ||= paper

        phase.tasks.create(evaluator.task_params)
        paper.reload
      end
    end

    factory :paper_ready_for_export do
      doi "blah/journal.yetijour.123334"

      after(:create) do |paper|
        editor = FactoryGirl.build(:user)
        FactoryGirl.create(:paper_role, :editor, paper: paper, user: editor)

        phase = create(:phase, paper: paper)

        # Authors
        authors_task = FactoryGirl.create(:authors_task, paper: paper)
        author = FactoryGirl.create(:author, paper: paper)
        paper.authors = [author]
        paper.creator = FactoryGirl.create(:user)
        NestedQuestionableFactory.create(
          author,
          questions: [
            {
              ident: 'other',
              answer: 'footstool',
              value_type: 'text'
            },
            {
              ident: 'desceased',
              answer: false,
              value_type: 'boolean'
            },
            {
              ident: 'published_as_corresponding_author',
              answer: true,
              value_type: 'boolean'
            },
            {
              ident: 'contributions',
              answer: true,
              value_type: 'boolean',
              questions: [
                {
                  ident: 'made_cookie_dough',
                  answer: true,
                  value_type: 'boolean'
                }
              ]
            }
          ]
        )

        # Financial Disclosure
        financial_task = create(:financial_disclosure_task, funders: [], paper: paper)
        NestedQuestionableFactory.create(
          financial_task,
          questions: [
            {
              ident: 'author_received_funding',
              answer: false,
              value_type: 'boolean'
            }
          ]
        )

        # Competing interests
        NestedQuestionableFactory.create(
          FactoryGirl.create(:competing_interests_task, paper: paper),
          questions: [
            {
              ident: 'competing_interests',
              answer: 'true',
              value_type: 'boolean',
              questions: [
                {
                  ident: 'statement',
                  answer: 'entered statement',
                  value_type: 'text'
                }
              ]
            }
          ]
        )

        # data availability
        NestedQuestionableFactory.create(
          FactoryGirl.create(:data_availability_task, paper: paper),
          questions: [
            {
              ident: 'data_fully_available',
              answer: 'true',
              value_type: 'boolean'
            },
            {
              ident: 'data_location',
              answer: 'holodeck',
              value_type: 'text'
            }
          ]
        )

        NestedQuestionableFactory.create(
          FactoryGirl.create(:production_metadata_task, paper: paper),
          questions: [
            {
              ident: 'publication_date',
              answer: '12/15/2025',
              value_type: 'text'
            }
          ]
        )

        version = paper.latest_version
        version.source = File.open(Rails.root.join('spec/fixtures/about_turtles.docx'))
        version.save!
        accept_decision = FactoryGirl.create(:decision)
        paper.decisions = [accept_decision]
        paper.save!

        paper.reload
      end
    end
  end
end
