class Api::AuthorGroupSerializer < ActiveModel::Serializer
  has_one :paper, embed: :id
  has_many :authors, embed: :ids, include: :true
end
