# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of NestedQuestionAnswer.
class QuestionAttachment < Attachment
  mount_uploader :file, QuestionAttachmentUploader

  def src
    non_expiring_proxy_url if done?
  end
end
