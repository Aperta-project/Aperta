class JournalSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo
  has_many :reviewers, embed: :ids, include: true, root: :users
end
