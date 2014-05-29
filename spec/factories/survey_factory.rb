FactoryGirl.define do
  factory :survey, class: ::Declaration::Survey do
    question "What is the cake?"
    answer "A lie!"
  end
end
