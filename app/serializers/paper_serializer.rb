class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title
  has_many :phases, embed: :ids, include: true
end
