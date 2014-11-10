class AdhocAttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/attachments/#{model.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :detail do
    process resize_to_limit: [986, -1]
  end

  version :preview do
    process :convert_to_png, if: :needs_transcoded?
    process resize_to_limit: [475, 220]

    def full_filename(orig_file)
      if needs_transcoded?(orig_file)
        "#{version_name}_#{File.basename(orig_file, ".*")}.png"
      else
        "#{version_name}_#{orig_file}"
      end
    end
  end

  private

  def convert_to_png
    manipulate! do |image|
      image.format("png")
      image
    end
    file.content_type = "image/png"
  end

  def needs_transcoded?(file)
    # On direct upload, the file's content_type is application/octet-stream, so
    # we also need to check the filename
    if file.respond_to?('content_type')
      ["image/tiff", "application/postscript"].include?(file.content_type)
    else
      !!(File.extname(file) =~ /(tif?f|eps)/i)
    end
  end

end
