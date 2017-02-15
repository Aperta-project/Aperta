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
               :reason,
               :links,
               :owner_type_for_answer
    has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :id, include: true
    has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true

    def links
      owner_params = { owner_id: object.id,
                       owner_type: object.class.name.underscore }
      # Need to use Rails.application ... here to avoid a problem with
      # double-nesting the API under /api/api
      {
        answers: Rails.application.routes.url_helpers
                      .answers_for_owner_path(owner_params),
        card: Rails.application.routes.url_helpers
                   .card_for_owner_path(owner_params)
      }
    end
  end
end
