require 'SecureRandom'

FactoryGirl.define do
  factory :paper do
    sequence :short_title do |n|
      "Test Paper - #{n}-#{SecureRandom.hex(3)}"
    end
    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end
    journal
    user

    trait(:completed) do
      submitted true
    end

    after(:build) do |paper|
      paper.paper_type ||= paper.journal.paper_types.first
      paper.build_default_author_groups
    end

    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.user).apply_template
      end
    end
  end
end
