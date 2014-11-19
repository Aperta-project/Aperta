require 'securerandom'

FactoryGirl.define do
  factory :paper do
    sequence :short_title do |n|
      "Test Paper - #{n}-#{SecureRandom.hex(3)}"
    end
    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    journal
    creator factory: User

    trait(:completed) do
      submitted true
    end

    after(:build) do |paper|
      paper.paper_type ||= paper.journal.paper_types.first
    end

    after(:create) do |paper|
      paper.paper_roles.create!(user: paper.creator, role: PaperRole::COLLABORATOR)
    end

    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.creator).apply_template
      end
    end
  end
end
