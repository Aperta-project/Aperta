class QuestionAttachment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :question

  mount_uploader :attachment, QuestionAttachmentUploader
end
