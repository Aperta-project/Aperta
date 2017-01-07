class ReviewerReportSerializer < ActiveModel::Serializer
  attributes :id,
             :decision_id,
             :user_id
  has_one :task
  has_many :nested_questions, embed: :ids, include: true
  has_many :nested_question_answers, embed: :ids, include: true
end