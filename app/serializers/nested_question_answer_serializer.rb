class NestedQuestionAnswerSerializer < ActiveModel::Serializer
  attributes :id, :value, :value_type, :owner, :nested_question_id
  has_one :attachment, embed: :id, include: true, root: :question_attachments
  has_one :decision, embed: :id, include: true

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

end
