FactoryGirl.define do
  factory :activity do
    user

    trait :uploaded_paper do
      association :subject, factory: [:paper, :accepted]
      message BillingLogReport::ACTIVITY_MESSAGE
    end
  end
end
