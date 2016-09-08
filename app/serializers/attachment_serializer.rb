# Generic Attachment serializer.
class AttachmentSerializer < ActiveModel::Serializer
  attributes :id,
    :title,
    :caption,
    :kind,
    :src,
    :status,
    :preview_src,
    :detail_src,
    :filename,
    :type
end
