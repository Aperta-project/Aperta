class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :assignees
  has_many :phases, embed: :ids, include: true
  has_many :assignees
end
