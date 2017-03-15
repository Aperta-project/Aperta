class ReviewerReportSerializer < ActiveModel::Serializer
  attributes :id,
    :decision_id,
    :user_id,
    :created_at,
    :status,
    :status_datetime,
    :revision
  has_one :task
  has_many :nested_questions, embed: :ids, include: true
  has_many :nested_question_answers, embed: :ids, include: true

  def status
    object.computed_status
  end

  def status_datetime
    object.computed_datetime
  end
end
