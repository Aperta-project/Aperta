FactoryGirl.define do
  factory :paper do
    sequence :short_title do |n|
      "Test Paper #{n}"
    end
    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids #{n}"
    end
    journal
    user
    after(:build) do |paper|
      paper.paper_type = paper.journal.paper_types.first
      paper.build_default_author_groups
    end
    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.user).apply_template
      end
    end
  end

  factory :manuscript do
    source Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/about_turtles.docx')))
  end

end
