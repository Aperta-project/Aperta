class AttachmentSerializer < ActiveModel::Serializer
  has_one :task, embed: :id, polymorphic: true

  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :detail_src, :filename

  def src
    object.file.url
  end

  def preview_src
    object.file.url(:preview) if object.image?
  end

  def detail_src
    object.file.url(:detail) if object.image?
  end
end
