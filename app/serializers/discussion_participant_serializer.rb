class DiscussionParticipantSerializer < AuthzSerializer
  attributes :id, :discussion_topic_id

  has_one :user,
          embed: :id,
          include: true,
          serializer: SensitiveInformationUserSerializer

  private

  def can_view?
    user.can?(:manage_participant, object)
  end
end
