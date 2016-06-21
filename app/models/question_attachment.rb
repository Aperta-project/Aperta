class QuestionAttachment < Attachment
  mount_uploader :file, QuestionAttachmentUploader

  def src
    non_expiring_proxy_url if done?
  end
end
