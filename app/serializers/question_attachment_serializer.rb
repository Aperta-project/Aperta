class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :filename, :src
  has_one :question, embed: :id

  def filename
    object[:attachment]
  end

  def src
    object.attachment.url
  end
end
