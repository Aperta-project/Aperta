FactoryGirl.define do

  factory :discussion_reply do
    body "Interesting discussion point."
    discussion_topic
    association :replier, factory: User
  end

end
