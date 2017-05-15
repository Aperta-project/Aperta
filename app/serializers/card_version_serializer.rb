class CardVersionSerializer < ActiveModel::Serializer
  attributes :id, :version, :card_id
  has_one :content_root, embed: :id, include: true, root: :card_contents
end
