class AdhocAttachmentUploader < AttachmentUploader
  def store_dir
    binding.pry
    "uploads/attachments/#{model.attachable.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
