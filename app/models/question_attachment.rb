class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :question

  mount_uploader :attachment, QuestionAttachmentUploader
end
