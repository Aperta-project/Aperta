class AdhocAttachmentUploader < AttachmentUploader

  def store_dir
    "uploads/attachments/#{model.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :detail do
    process resize_to_limit: [986, -1], if: :image?
    process :convert_to_png, if: :needs_transcoding?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  version :preview do
    process resize_to_limit: [475, 220], if: :image?
    process :convert_to_png, if: :needs_transcoding?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end
end
