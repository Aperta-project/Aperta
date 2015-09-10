class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value, :value_type
  has_many :children, serializer: NestedQuestionSerializer
end
