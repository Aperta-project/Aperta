FactoryGirl.define do
  factory :comment do
    body "Here is a sample comment"
    task

    trait :with_comment_look do
      after(:create) do |comment|
        CommentLookManager.sync(comment.task)
      end
    end
  end
end
