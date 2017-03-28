# Generic Attachment serializer.
class AttachmentSerializer < ActiveModel::Serializer
  attributes :id,
    :title_html,
    :caption_html,
    :file_type,
    :src,
    :status,
    :preview_src,
    :detail_src,
    :filename,
    :type
end
