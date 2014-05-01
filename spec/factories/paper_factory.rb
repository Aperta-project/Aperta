FactoryGirl.define do
  factory :paper do
    sequence :short_title do |n|
      "Test Paper #{n}"
    end
    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids #{n}"
    end
    paper_type "research"
    journal
  end
end
