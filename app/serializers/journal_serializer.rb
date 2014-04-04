class JournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url
  has_many :reviewers, embed: :ids, include: true, root: :users
end
