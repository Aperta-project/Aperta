class TableSerializer < ActiveModel::Serializer
  attributes :id, :title, :caption, :body, :created_at
  has_one :paper, embed: :id
end
