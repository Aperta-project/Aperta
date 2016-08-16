# Serializes InvitationAttachmnent(s).
class InvitationAttachmentSerializer < ActiveModel::Serializer
  has_one :invitation, embed: :id

  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :detail_src, :filename, :type

  def invitation
    object.owner
  end
end
