FactoryGirl.define do
  factory :plos_author, class: "PlosAuthors::PlosAuthor" do
    first_name "Luke"
    middle_initial "J"
    last_name "Skywalker"
    department "Jedis"
    title "Head Jedi"
    affiliation 'university of dagobah'
    position 1
    email
  end
end


