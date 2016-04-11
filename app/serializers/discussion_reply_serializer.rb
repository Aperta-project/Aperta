class DiscussionReplySerializer < ActiveModel::Serializer
  attributes :id, :discussion_topic_id, :body, :created_at

  has_one :replier, embed: :id, include: true, root: 'users'
end
