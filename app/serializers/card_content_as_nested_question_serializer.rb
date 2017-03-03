class CardContentAsNestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value_type, :owner, :position

  def owner
    { id: nil, type: object.card.name }
  end

  # Previously used for ordering. Now we just use lft
  def position
    object.lft
  end
end
