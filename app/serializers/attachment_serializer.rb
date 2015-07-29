class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :attachable, :filename

  def src
    object.file.url
  end

  def attachable
    {
      type: object.task.class.name,
      id: object.task.id
    }
  end

  def preview_src
    object.file.preview.url if object.image?
  end
end
