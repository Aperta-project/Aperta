# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of NestedQuestionAnswer.
class QuestionAttachment < Attachment
  mount_uploader :file, QuestionAttachmentUploader

  def download!(url)
    file.download!(url)
    update_attributes!(status: STATUS_DONE)
  end

  def src
    non_expiring_proxy_url if done?
  end
end
