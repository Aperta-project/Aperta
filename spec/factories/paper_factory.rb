require 'securerandom'

FactoryGirl.define do
  factory :paper do
    journal
    paper_type { journal.paper_types.first || "research" }

    uses_research_article_reviewer_report true

    after(:stub) do |paper|
      doi_number = paper.journal.last_doi_issued.to_i + 1
      paper.journal.last_doi_issued = doi_number.to_s
      paper.short_doi = "#{paper.journal.doi_publisher_prefix}.#{doi_number}"
    end

    trait :with_integration_journal do
      association :journal, factory: :journal_with_roles_and_permissions
    end

    trait :with_creator do
      after(:create) do |paper|
        if paper.journal
          paper.journal.creator_role || paper.journal.create_creator_role!
        end

        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
      end
    end

    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    trait :with_phases do
      transient do
        phases_count 1
      end

      after(:create) do |paper, evaluator|
        paper.phases << FactoryGirl.build_list(:phase, evaluator.phases_count)
      end
    end

    trait(:active) do
      # noop
    end

    trait(:withdrawn_lite) do
      transient do
        reason nil
        withdrawn_by_user { build(:user) }
      end

      active false
      editable false
      state_updated_at { DateTime.current.utc }
      publishing_state "withdrawn"

      after(:build) do |paper, evaluator|
        paper.withdrawals = build_list(
          :withdrawal,
          1,
          paper: paper,
          reason: evaluator.reason,
          withdrawn_by_user: evaluator.withdrawn_by_user
        )
      end
    end

    trait(:checking) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
        paper.minor_check! paper.creator
      end
    end

    trait(:accepted) do
      publishing_state "accepted"
    end

    # TODO: find all cases where this trait is used and change to trait of 'submitted'
    trait(:completed) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
      end
    end

    trait(:initially_submitted) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.initial_submit! paper.creator
      end
    end

    trait(:submitted) do
      after(:create) do |paper|
        paper.update!(creator: FactoryGirl.create(:user)) unless paper.creator
        paper.submit! paper.creator
      end
    end

    trait(:submitted_lite) do
      transient do
        submitting_user { FactoryGirl.create(:user) }
      end
      publishing_state :submitted
      editable false
      # Time in { } to evaluate it later so that it works with Timecop
      first_submitted_at { DateTime.current.utc }
      submitted_at { DateTime.current.utc }
      state_updated_at { DateTime.current.utc }
      after :create do |paper, evaluator|
        paper.new_draft_decision!
        paper.versioned_texts.first.update!(
          major_version: 0,
          minor_version: 0,
          submitting_user: evaluator.submitting_user
        )
      end
    end

    trait(:version_with_file_type) do
      after :create do |paper|
        paper.file = FactoryGirl.create(
          :manuscript_attachment,
          paper: paper,
          file_type: 'docx',
          file: File.open(Rails.root.join('spec/fixtures/about_turtles.docx')),
          s3_dir: 'sample/dir',
          status: 'done'
        )

        paper.save!

        paper.versioned_texts.first.update!(
          file_type: 'docx'
        )
      end
    end

    trait(:initially_submitted_lite) do
      submitted_lite
      publishing_state :initially_submitted
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
        unless Card.exists?
          start = Time.now
          CardLoader.load_standard
          end_time = Time.now
          puts "seeded cards in test in #{end_time - start} seconds"
        end
        FactoryGirl.create(:early_posting_task, :with_loaded_card)
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
          :with_card,
          paper: paper
        )
        card_content = FactoryGirl.create(
          :card_content,
          parent: task.card.content_root_for_version(:latest),
          ident: 'publishing_related_questions--short_title'
        )
        task.find_or_build_answer_for(card_content: card_content,
                                      value: evaluator.short_title).save
      end
    end

    trait(:gradual_engagement) do
      after(:create) do |paper|
        task_type_id = JournalTaskType.find_by(title: 'Initial Decision').id.to_s
        initial_decision_params = { "paper_type" => "Gradual Engagement", "journal_id" => paper.journal.id,
                                    "phase_templates" => [{ "name" => "Phase 1", "position" => 1,
                                                            "task_templates" => [
                                                              { "title" => "Initial Decision", "journal_task_type_id" => task_type_id, "position" => 2 }
                                                            ] },
                                                          { "name" => "Phase 2", "position" => 2 },
                                                          { "name" => "Phase 3", "position" => 3 }] }
        ManuscriptManagerTemplateForm.new(initial_decision_params).create!
        paper.update_column(:paper_type, 'Gradual Engagement')
        PaperFactory.new(paper.reload, paper.creator).add_phases_and_tasks
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
            raise ex
          end
        end
      end
    end

    trait(:with_co_authors) do
      after(:create) do |paper|
        FactoryGirl.create(
          :assignment,
          role: FactoryGirl.create(:role, :creator),
          user: FactoryGirl.build(:user),
          assigned_to: paper
        )
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

    trait(:with_versions_across_file_types) do
      transient do
        first_version_body  'first body'
        second_version_body 'second body'
        third_version_body 'third body'
      end

      after(:create) do |paper, evaluator|
        # 0.0, 0.1, 0.2, 1.0, Draft
        paper.body = evaluator.first_version_body
        paper.save!
        paper.submit! paper.creator

        paper.major_revision!
        paper.body = evaluator.second_version_body
        paper.save!

        paper.draft.be_minor_version!
        paper.new_draft!
        paper.draft.be_minor_version!
        paper.save!

        # New manuscript is a uploaded
        paper.file = FactoryGirl.create(
          :manuscript_attachment,
          paper: paper,
          file_type: 'pdf',
          file: File.open(Rails.root.join('spec/fixtures/about_turtles.pdf')),
          s3_dir: 'sample/dir',
          status: 'done'
        )

        paper.save!

        paper.versioned_texts.last.update!(
          file_type: 'pdf'
        )
        paper.new_draft!

        paper.submit! paper.creator

        paper.major_revision!
        paper.body = evaluator.third_version_body
        paper.save!
      end
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
        evaluator.task_params[:type] ||= "Task"
        evaluator.task_params[:paper] ||= paper

        unless evaluator.task_params[:card_version]
          task_klass_name = evaluator.task_params[:type]
          CardLoader.load(task_klass_name)
          card = Card.find_by_class_name(task_klass_name)
          evaluator.task_params[:card_version] = card.latest_published_card_version
        end

        phase.tasks.create(evaluator.task_params)
        paper.reload
      end
    end

    trait :ready_for_export do
      doi "blah/journal.yetijour.123334"
      publishing_state "accepted"

      with_integration_journal

      after(:create) do |paper|
        editor = FactoryGirl.build(:user)

        phase = create(:phase, paper: paper)

        # Authors
        authors_task = FactoryGirl.create(:authors_task, paper: paper)
        author = FactoryGirl.create(:author, paper: paper)
        paper.authors = [author]
        paper.creator = FactoryGirl.create(:user)
        AnswerableFactory.create(
          author,
          questions: [
            {
              ident: 'authors--other',
              answer: 'footstool',
              value_type: 'text'
            },
            {
              ident: 'authors--desceased',
              answer: false,
              value_type: 'boolean'
            },
            {
              ident: 'authors--published_as_corresponding_author',
              answer: true,
              value_type: 'boolean'
            },
            {
              ident: 'authors--contributions',
              answer: true,
              value_type: 'boolean',
              questions: [
                {
                  ident: 'authors--made_cookie_dough',
                  answer: true,
                  value_type: 'boolean'
                }
              ]
            }
          ]
        )

        # Financial Disclosure
        financial_task = create(:financial_disclosure_task, funders: [], paper: paper)
        AnswerableFactory.create(
          financial_task,
          questions: [
            {
              ident: 'financial_disclosure--author_received_funding',
              answer: false,
              value_type: 'boolean'
            }
          ]
        )

        # Competing interests
        AnswerableFactory.create(
          FactoryGirl.create(:competing_interests_task, paper: paper),
          questions: [
            {
              ident: 'competing_interests--competing_interests',
              answer: 'true',
              value_type: 'boolean',
              questions: [
                {
                  ident: 'competing_interests--statement',
                  answer: 'entered statement',
                  value_type: 'text'
                }
              ]
            }
          ]
        )

        # data availability
        AnswerableFactory.create(
          FactoryGirl.create(:data_availability_task, paper: paper),
          questions: [
            {
              ident: 'data_availability--data_fully_available',
              answer: 'true',
              value_type: 'boolean'
            },
            {
              ident: 'data_availability--data_location',
              answer: 'holodeck',
              value_type: 'text'
            }
          ]
        )

        AnswerableFactory.create(
          FactoryGirl.create(:production_metadata_task, paper: paper),
          questions: [
            {
              ident: 'production_metadata--publication_date',
              answer: '12/15/2025',
              value_type: 'text'
            }
          ]
        )

        paper.file = FactoryGirl.create(
          :manuscript_attachment,
          paper: paper,
          file: File.open(Rails.root.join('spec/fixtures/about_turtles.docx')),
          pending_url: 'http://tahi-test.s3.amazonaws.com/temp/about_turtles.docx'
        )
        accept_decision = FactoryGirl.create(:decision)
        paper.decisions = [accept_decision]
        paper.save!

        paper.reload
      end
    end
  end
end
