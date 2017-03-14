# Sends Answers to the frontend in the same shape as NestedQuestionAnswers
class AnswerAsNestedQuestionAnswerSerializer < ActiveModel::Serializer
  root :nested_question_answer
  attributes :id, :value_type, :owner, :nested_question_id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

  def nested_question_id
    object.card_content_id
  end
end
