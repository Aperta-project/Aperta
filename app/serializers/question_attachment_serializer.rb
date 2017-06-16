class QuestionAttachmentSerializer < ActiveModel::Serializer
  include ReadySerializable

  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src
end
