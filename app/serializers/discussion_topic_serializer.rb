class DiscussionTopicSerializer < AuthzSerializer
  attributes :id, :paper_id, :title, :created_at

  has_many :participants, embed: :ids, include: true, root: 'users', serializer: FilteredUserSerializer
  has_many :discussion_participants, embed: :ids, include: true
  has_many :discussion_replies, embed: :ids, include: true
end
