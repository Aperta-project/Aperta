class CardContentSerializer < ActiveModel::Serializer
  attributes :id, :ident, :text, :value_type, :content_type, :order

  has_many :children, embed: :ids, include: true, root: :card_contents, key: :unsorted_child_ids

  def order
    object.lft
  end
end
