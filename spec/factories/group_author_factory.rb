FactoryGirl.define do
  factory :group_author do
    sequence(:position) { |n| n }
    paper

    contact_first_name "Luke"
    contact_middle_name "J"
    contact_last_name "Skywalker"
    contact_email "luke@monkislandplanet.com"
    name "Jedis"
    initial "F"
  end
end
