FactoryGirl.define do
  factory :comment do
    body "Here is a sample comment"
    association :commenter, factory: :user
    task
  end
end
