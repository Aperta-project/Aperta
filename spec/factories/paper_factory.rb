require 'securerandom'

FactoryGirl.define do
  factory :paper do
    journal
    creator factory: User

    sequence :short_title do |n|
      "Test Paper - #{n}-#{SecureRandom.hex(3)}"
    end

    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    trait(:completed) do
      submitted true
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

    after(:build) do |paper|
      paper.paper_type ||= paper.journal.paper_types.first
    end

    after(:create) do |paper|
      paper.paper_roles.create!(user: paper.creator, role: PaperRole::COLLABORATOR)
      paper.create_decision!
    end
  end
end
