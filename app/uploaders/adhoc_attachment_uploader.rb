class AdhocAttachmentUploader < AttachmentUploader
  def store_dir
    model.try(:s3_dir) ||
      "uploads/attachments/#{model.id}/attachment/file/#{model.id}"
  end
end
