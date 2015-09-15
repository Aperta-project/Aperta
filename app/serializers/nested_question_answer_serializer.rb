class NestedQuestionAnswerSerializer < ActiveModel::Serializer
  attributes :id, :value, :value_type, :owner, :nested_question_id

  def owner
    { id: object.owner_id, type: object.owner_type }
  end

end
