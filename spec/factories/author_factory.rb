FactoryGirl.define do
  factory :author do
    sequence(:position){ |n| n }
    paper
    authors_task

    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    author_initial "LS"
    email
    department "Jedis"
    title "Head Jedi"
    affiliation 'university of dagobah'
  end
end
