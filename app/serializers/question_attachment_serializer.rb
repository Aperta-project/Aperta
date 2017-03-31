class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :title_html, :caption_html, :status, :filename, :src
end
