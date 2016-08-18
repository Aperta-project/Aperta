# Serializes InvitationAttachmnent(s).
class InvitationAttachmentSerializer < AttachmentSerializer
  has_one :invitation, embed: :id

  def invitation
    object.owner
  end
end
