class DiscussionParticipantSerializer < AuthzSerializer
  attributes :id, :discussion_topic_id

  has_one :user,
          embed: :id,
          include: true,
          serializer: SensitiveInformationUserSerializer

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
