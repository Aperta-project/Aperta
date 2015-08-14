require 'securerandom'

FactoryGirl.define do
  factory :paper do
    after(:create) do |paper|
      paper.save!
      paper.body = "I am the very model of a modern journal article"
    end

    journal
    creator factory: User

    sequence :short_title do |n|
      "Test Paper - #{n}-#{SecureRandom.hex(3)}"
    end

    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    # TODO: find all cases where this trait is used and change to trait of 'submitted'
    trait(:completed) do
      publishing_state "submitted"
    end

    trait(:submitted) do
      after(:create) do |paper|
        paper.submit! paper.creator
      end
    end

    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.creator).apply_template
      end
    end

    trait(:with_valid_plos_author) do
      after(:create) do |paper|
        FactoryGirl.create(
          :plos_author,
          paper: paper,
          plos_authors_task: paper.tasks.find_by(type: "PlosAuthors::PlosAuthorsTask")
        )
      end
    end

    trait(:with_editor) do
      after(:create) do |paper|
        editor = FactoryGirl.build(:user)
        FactoryGirl.create(:paper_role, :editor, paper: paper, user: editor)
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
      paper.paper_roles.create!(user: paper.creator, role: PaperRole::COLLABORATOR)
      paper.decisions.create!

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
        evaluator.task_params[:role] ||= "user"
        evaluator.task_params[:type] ||= "Task"

        phase.tasks.create(evaluator.task_params)
        paper.reload
      end
    end
  end
end
