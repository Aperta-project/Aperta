class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :content_type,
             :unsorted_child_ids,
             :ident,
             :order

  def order
    object.lft
  end

  # Doing it this way is much faster than hitting each attribute
  def attributes
    hash = super
    object.content_attributes.each do |attr|
      hash[attr.name.to_sym] = attr.value
    end
    hash
  end

  def unsorted_child_ids
    # Memoize this because it is called multiple times.
    @unsorted_child_ids ||= object.quick_unsorted_child_ids
  end
end
