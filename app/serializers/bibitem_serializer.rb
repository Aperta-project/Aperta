class BibitemSerializer < ActiveModel::Serializer
  attributes :id, :format, :content, :created_at
  has_one :paper, embed: :id
end
