class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :filename, :src

  def src
    object.attachment.url
  end
end
