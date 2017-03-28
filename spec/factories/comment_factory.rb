FactoryGirl.define do
  factory :comment do
    body_html "Here is a sample comment"
    association :commenter, factory: :user
    association :task, factory: :ad_hoc_task
  end
end
