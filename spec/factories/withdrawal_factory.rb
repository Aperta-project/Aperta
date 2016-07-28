FactoryGirl.define do
  factory :withdrawal do
    paper
    previous_publishing_state 'unsubmitted'
  end
end
