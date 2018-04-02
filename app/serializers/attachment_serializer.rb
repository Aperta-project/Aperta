# Generic Attachment serializer.
class AttachmentSerializer < AuthzSerializer
  attributes :id,
    :title,
    :caption,
    :file_type,
    :src,
    :status,
    :preview_src,
    :detail_src,
    :filename,
    :type,
    :pending_url,
    :file_hash
end
