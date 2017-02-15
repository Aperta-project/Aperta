class CardSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :card_content, embed: :ids, include: true
  has_one :content_root, embed: :id
end
