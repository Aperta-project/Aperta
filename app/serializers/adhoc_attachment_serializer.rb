# Serializes AdhocAttachment(s).
class AdhocAttachmentSerializer < AttachmentSerializer
  has_one :task, embed: :id, polymorphic: true
end
