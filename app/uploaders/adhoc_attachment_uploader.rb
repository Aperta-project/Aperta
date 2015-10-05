class AdhocAttachmentUploader < AttachmentUploader

  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/attachments/#{model.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :detail, if: :is_image? do
    process resize_to_limit: [986, -1], if: :image?
    process :convert_to_png, if: :needs_transcoding?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  version :preview, if: :is_image? do
    process resize_to_limit: [475, 220], if: :image?
    process :convert_to_png, if: :needs_transcoding?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  protected

  def is_image?(_image)
    model.image?
  end
end
