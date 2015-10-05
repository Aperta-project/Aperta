class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :filename, :src

  def filename
    object[:attachment]
  end

  def src
    object.attachment.url
  end
end
