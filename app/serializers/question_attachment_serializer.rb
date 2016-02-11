class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :caption, :status, :filename, :src
end
