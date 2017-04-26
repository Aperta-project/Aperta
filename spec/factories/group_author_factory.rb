FactoryGirl.define do
  factory :group_author do
    paper
    card_version

    contact_first_name "Luke"
    contact_middle_name "J"
    contact_last_name "Skywalker"
    contact_email "luke@monkislandplanet.com"
    name "Jedis"
    initial "F"
    co_author_state_modified_at DateTime.current

  end
end
