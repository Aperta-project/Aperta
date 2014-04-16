class JournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :paper_types
  has_many :reviewers, embed: :ids, include: true, root: :users
end
