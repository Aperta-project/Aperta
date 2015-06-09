class DiscussionTopicIndexSerializer < ActiveModel::Serializer
  attributes :id, :paper_id, :title, :created_at

  has_many :discussion_participants, embed: :ids, include: true
  has_many :participants, embed: :ids, include: true, root: 'users'

end
