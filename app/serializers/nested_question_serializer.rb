class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value, :value_type, :task_id
  has_many :children, serializer: NestedQuestionSerializer

  def task_id
    object.owner_id
  end
end
