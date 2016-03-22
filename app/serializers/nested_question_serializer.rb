class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value_type, :owner, :position

  def owner
    { id: object.owner_id, type: object.owner_type }
  end
end
