FactoryGirl.define do
  factory :paper_tracker_query do
    sequence :title do |n|
      "Tracker Query ##{n}"
    end

    sequence :query do |n|
      "TASK authors COMPLETED > #{n} DAYS"
    end
  end
end
