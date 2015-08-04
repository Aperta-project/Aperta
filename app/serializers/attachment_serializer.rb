class AttachmentSerializer < ActiveModel::Serializer
  has_one :task, embed: :id

  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :detail_src, :filename

  def src
    object.file.url
  end

  def preview_src
    object.file.preview.url if object.image?
  end

  def detail_src
    object.file.url if object.image?
  end
end
