class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :content_type

  has_many :children,
           embed: :ids,
           include: true,
           root: :card_contents,
           key: :unsorted_child_ids

  def order
    object.lft
  end

  # Doing it this way is faster than hitting each attribute
  def attributes
    hash = super
    object.content_attributes.each do |attr|
      hash[attr.name] = attr.value
    end
    hash
  end
end
