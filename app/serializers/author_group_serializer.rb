class AuthorGroupSerializer < ActiveModel::Serializer
  attributes :id,
    :name
  has_many :authors, embed: :id, include: true
end
