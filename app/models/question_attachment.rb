class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifier

  belongs_to :question

  mount_uploader :attachment, QuestionAttachmentUploader
end
