class DiscussionParticipantSerializer < ActiveModel::Serializer
  attributes :id, :discussion_topic_id

  has_one :user,
          embed: :id,
          include: true,
          serializer: SensitiveInformationUserSerializer
end
