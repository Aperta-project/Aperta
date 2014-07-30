class QuestionAttachment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :question

  mount_uploader :attachment, QuestionAttachmentUploader

  def filename
    self[:attachment]
  end

  def src
    attachment.url
  end

  def notifier_payload
    { id: id, paper_id: paper.id }
  end
end
