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
        correponding_author_question = CardContent.where(
          ident: Author::CORRESPONDING_QUESTION_IDENT,
          value_type: 'boolean'
        ).first_or_create!
        author.answers << FactoryGirl.create(
          :answer,
          :boolean_yes,
          card_content: correponding_author_question
        )
      end
    end
  end
end
