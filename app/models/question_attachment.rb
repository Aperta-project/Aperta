class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :nested_question_answer

  mount_uploader :attachment, QuestionAttachmentUploader

  def paper
    nested_question_answer.owner.paper
  end
end
