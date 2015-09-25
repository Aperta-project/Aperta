class DecisionSerializer < ActiveModel::Serializer
  attributes :id, :verdict, :revision_number, :letter, :is_latest, :created_at, :author_response
  has_many :invitations, embed: :ids, include: true
  has_many :questions, embed: :ids, include: true
  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
  has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true

  def is_latest
    object.latest?
  end
end
