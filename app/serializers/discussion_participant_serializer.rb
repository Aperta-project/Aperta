class DiscussionParticipantSerializer < ActiveModel::Serializer
  attributes :id, :discussion_topic_id, :user_id

end
