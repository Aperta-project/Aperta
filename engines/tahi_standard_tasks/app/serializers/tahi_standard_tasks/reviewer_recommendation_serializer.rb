module TahiStandardTasks
  class ReviewerRecommendationSerializer < ActiveModel::Serializer
    attributes :id,
               :first_name,
               :middle_initial,
               :last_name,
               :email,
               :title,
               :department,
               :affiliation,
               :ringgold_id,
               :recommend_or_oppose,
               :reason
    has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :id, include: true
    has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true

  end
end
