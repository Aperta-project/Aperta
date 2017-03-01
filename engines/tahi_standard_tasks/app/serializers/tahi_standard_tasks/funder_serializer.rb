module TahiStandardTasks
  class FunderSerializer < ActiveModel::Serializer
    attributes :additional_comments, :id, :name, :grant_number, :website, :links, :owner_type_for_answer

    has_one :task, embed: :ids
    has_many :authors, embed: :ids, include: true
    has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
    has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true
    has_one :card, embed: :id

    def links
      owner_params = { owner_id: object.id,
                       owner_type: object.class.name.underscore }
      # Need to use Rails.application ... here to avoid a problem with
      # double-nesting the API under /api/api
      {
        answers: Rails.application.routes.url_helpers
                      .answers_for_owner_path(owner_params)
      }
    end
  end
end
