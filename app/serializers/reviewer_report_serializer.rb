class ReviewerReportSerializer < ActiveModel::Serializer
  attributes :id,
    :decision_id,
    :user_id,
    :created_at,
    :status,
    :status_date,
    :revision,
    :owner_type_for_answer,
    :links
  has_one :task
  has_many :nested_questions, embed: :ids, include: true
  has_many :nested_question_answers, embed: :ids, include: true
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
