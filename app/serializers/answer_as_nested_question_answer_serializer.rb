# Sends Answers to the frontend in the same shape as NestedQuestionAnswers
class AnswerAsNestedQuestionAnswerSerializer < ActiveModel::Serializer
  root :nested_question_answer
  attributes :id, :value, :value_type, :owner, :nested_question_id, :decision_id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

  def value
    object.coerced_value
  end

  def nested_question_id
    object.card_content_id
  end

  def decision_id
    # TODO: What goes here? The client doesn't actually use decision ids on
    # answers anymore anyways (Reviewer Reports made them obsolete)
  end
end
