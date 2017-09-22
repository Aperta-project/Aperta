class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :content_type,
             :unsorted_child_ids
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

  def unsorted_child_ids
    @unsorted_child_ids ||= object.quick_unsorted_child_ids
  end
end
