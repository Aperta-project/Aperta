FactoryGirl.define do
  factory :snapshot do
    paper

    major_version 1
    minor_version 1

    after(:build) do |snapshot|
      snapshot.source ||= FactoryGirl.create(:ad_hoc_task)
    end
  end
end
