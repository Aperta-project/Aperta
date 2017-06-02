class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src,
             :ready,
             :ready_issues
end
