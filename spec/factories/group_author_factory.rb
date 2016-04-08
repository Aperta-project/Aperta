FactoryGirl.define do
  factory :group_author do
    paper

    contact_first_name "Luke"
    contact_middle_name "J"
    contact_last_name "Skywalker"
    contact_email "luke@monkislandplanet.com"
    name "Jedis"
    initial "F"

    after(:create) do |instance|
      instance.position = 1
      instance.save
    end
  end
end
