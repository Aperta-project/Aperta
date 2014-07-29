FactoryGirl.define do
  factory :author do
    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    department "Jedis"
    title "Head Jedi"
    affiliation 'university of dagobah'
    position 1
    author_group
    email
  end
end
