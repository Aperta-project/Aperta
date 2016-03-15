FactoryGirl.define do
  factory :author do
    paper

    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    author_initial "LS"
    email
    department "Jedis"
    title "Head Jedi"
    affiliation 'university of dagobah'

    after(:create) do |instance|
      instance.task = FactoryGirl.create :authors_task
    end
  end
end
