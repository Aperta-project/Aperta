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

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
