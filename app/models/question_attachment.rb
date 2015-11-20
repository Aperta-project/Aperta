class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :nested_question_answer

  mount_uploader :attachment, QuestionAttachmentUploader

  def paper
    question.owner.paper
  end
end
