class AuthorGroupSerializer < ActiveModel::Serializer
  attributes :id,
    :name
  has_many :authors, embed: :id, include: true
  has_one :paper, embed: :id
end
