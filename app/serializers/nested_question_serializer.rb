class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :text, :ident, :value_type
  has_many :children, serializer: NestedQuestionSerializer
end
