class AnswerAsNestedQuestionAnswerSerializer < ActiveModel::Serializer
  attributes :id, :value, :value_type, :owner, :nested_question_id, :decision_id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

  def nested_question_id
    object.card_content_id
  end

  def decision_id
    # TODO: What goes here?
  end
end
