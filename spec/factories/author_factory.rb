FactoryGirl.define do
  factory :author do
    position 1
    paper
    authors_task

    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    email
    department "Jedis"
    deceased false
    corresponding true
    title "Head Jedi"
    affiliation 'university of dagobah'
    contributions ["brought cookies"]
  end
end
