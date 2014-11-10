class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :src, :status, :preview_src, :attachable

  def src
    object.file.url
  end

  def attachable
    {
      type: object.attachable_type,
      id: object.attachable_id
    }
  end

  def preview_src
    object.file.preview.url
  end
end
