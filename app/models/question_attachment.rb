class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :nested_question_answer, inverse_of: :attachment

  mount_uploader :attachment, QuestionAttachmentUploader

  def paper
    nested_question_answer.owner.try(:paper)
  end
end
