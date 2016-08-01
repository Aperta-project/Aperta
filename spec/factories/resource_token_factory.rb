FactoryGirl.define do
  factory :resource_token do
    sequence(:token) { SecureRandom.uuid }
  end
end
