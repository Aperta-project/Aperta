class CardContentSerializer < ActiveModel::Serializer
  attributes :id,
             :content_type,
             :unsorted_child_ids,
             :ident,
             :order

  # TODO: this probably adds an n+1 query
  # TODO: maybe look into always resolving the repetitions promise when opening a task instead of `include: true`
  has_many :repetitions, embed: :ids, include: true

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
end
