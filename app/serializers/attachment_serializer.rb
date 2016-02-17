class AttachmentSerializer < ActiveModel::Serializer
  include SideloadableSerializerHelper

  has_one :task, embed: :id, polymorphic: true

  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :detail_src, :filename

  side_load :permissions

  def src
    object.file.url
  end

  def preview_src
    object.file.url(:preview) if object.image?
  end

  def detail_src
    object.file.url(:detail) if object.image?
  end

  def permissions
    current_user.filter_authorized(:view, object.task).serializable
  end
end
