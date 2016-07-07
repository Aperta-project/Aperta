class AdhocAttachmentUploader < AttachmentUploader
  def store_dir
    "uploads/attachments/#{model.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
