# Serializes CorrespondenceAttachmnent(s).
class CorrespondenceAttachmentSerializer < AttachmentSerializer
  has_one :correspondence, embed: :id

  def correspondence
    object.owner
  end
end
