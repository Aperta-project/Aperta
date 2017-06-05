class QuestionAttachmentSerializer < ReadyableSerializer

  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src
end
