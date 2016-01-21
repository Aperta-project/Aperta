class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :filename, :src
end
