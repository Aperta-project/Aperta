class AttachmentsSerializer < ActiveModel::ArraySerializer
  include PolyArraySerializer

  self.each_serializer = AttachmentSerializer
end
