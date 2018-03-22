class CardContentSerializer < AuthzSerializer
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
    object.entity_attributes.each do |attr|
      hash[attr.name.to_sym] = attr.value
    end
    hash
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
