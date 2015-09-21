class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :question, polymorphic: true

  mount_uploader :attachment, QuestionAttachmentUploader
end
