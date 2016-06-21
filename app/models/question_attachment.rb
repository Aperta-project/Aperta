class QuestionAttachment < Attachment
  mount_uploader :file, QuestionAttachmentUploader

  def paper
    nested_question_answer.owner.try(:paper)
  end

  def src
    non_expiring_proxy_url if done?
  end
end
