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

    trait :corresponding do
      after(:create) do |author|
        corresponding_author_question = CardContent.find_by!(
          ident: Author::CORRESPONDING_QUESTION_IDENT,
        )
        corresponding_author_question.answers.create(owner: author, paper: author.paper, value: 't')
      end
    end
  end
end
