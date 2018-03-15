class DiscussionParticipantSerializer < AuthzSerializer
  attributes :id, :discussion_topic_id

  has_one :user, embed: :id, include: true, serializer: FilteredUserSerializer
end
