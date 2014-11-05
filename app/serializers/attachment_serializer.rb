class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :src, :preview_src

  def src
    object.file.url
  end

  def preview_src
    object.file.preview.url
  end
end
