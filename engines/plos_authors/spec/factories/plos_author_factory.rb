FactoryGirl.define do
  factory :plos_author, class: "PlosAuthors::PlosAuthor" do
    plos_authors_task
    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    email
    department "Jedis"
    deceased true
    corresponding true
    title "Head Jedi"
    affiliation 'university of dagobah'
    position 1
  end
end
