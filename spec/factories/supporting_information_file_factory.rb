FactoryGirl.define do
  factory :supporting_information_file do
    association :owner, factory: :supporting_information_task
    paper
  end
end
