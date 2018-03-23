class QuestionAttachmentSerializer < AuthzSerializer
  include ReadySerializable

  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src
end
