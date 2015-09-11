class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value_type, :task
  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true

  def task
    { id: object.owner_id, type: object.owner_type }
  end

  def nested_questions
    object.children
  end
end
