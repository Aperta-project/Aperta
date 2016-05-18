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

    after(:create) do |author|
      author.position = 1
      author.save
    end

    trait :corresponding do
      after(:create) do |author|
        correponding_author_question = NestedQuestion.where(
          ident: Author::CORRESPONDING_QUESTION_IDENT
        ).first_or_create!
        author.nested_question_answers << FactoryGirl.create(
          :nested_question_answer,
          :boolean_yes,
          nested_question: correponding_author_question
        )
      end
    end
  end
end
