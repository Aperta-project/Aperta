class DiscussionTopicIndexSerializer < ActiveModel::Serializer
  attributes :id, :paper_id, :title, :created_at

  # has_many :discussion_participants

end
