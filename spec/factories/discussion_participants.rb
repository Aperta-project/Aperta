FactoryGirl.define do
  factory :discussion_participant do
    discussion_topic
    user
  end

end
