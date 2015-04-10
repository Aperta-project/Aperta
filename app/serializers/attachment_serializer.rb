class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :caption, :src, :status, :preview_src, :created_at, :updated_at, :attachable

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
    object.file.preview.url if object.image?
  end
end
