class AttachmentUploader < CarrierWave::Uploader::Base
  require 'mini_magick'
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/paper/#{model.paper.id}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :detail do
    process convert_image: ["984x-1>"], if: :image?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  version :preview do
    process convert_image: ["475x220"], if: :image?

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  private

  def convert_image(size)
    image = MiniMagick::Image.open(current_path)
    temp_file = MiniMagick::Utilities.tempfile(".png")
    MiniMagick::Tool::Convert.new do |convert|
      convert.merge! image_density(image)
      convert.merge! image_colorspace(image)
      convert.merge! ["-resize", size]
      convert << current_path
      convert.merge! ["-colorspace", "sRGB"]
      convert << temp_file.path
    end
    FileUtils.cp(temp_file.path, current_path)
    file.content_type = "image/png"
  end

  def full_name(orig_file)
    if needs_transcoding?(orig_file)
      "#{version_name}_#{File.basename(orig_file, '.*')}.png"
    else
      "#{version_name}_#{orig_file}"
    end
  end

  def image_density(image)
    return [] unless image.details['Total ink density']
    ['-density', image.details['Total ink density']]
  end

  def image_colorspace(image)
    return [] unless image.details['Colorspace']
    ['-colorspace', image.details['Colorspace']]
  end

  def needs_transcoding?(file)
    # On direct upload, the file's content_type is application/octet-stream, so
    # we also need to check the filename
    if file.respond_to?('content_type')
      ["image/tiff", "application/postscript", "image/x-eps"].include?(file.content_type)
    else
      !!(File.extname(file) =~ /(tif?f|eps)/i)
    end
  end

  def image?(file)
    if file.respond_to?('content_type')
      ["image/tiff", "application/postscript", "image/x-eps", "image/jpeg", "image/png", "image/gif"].include?(file.content_type)
    else
      !!(File.extname(file) =~ /(tif?f|eps|jpg|jpeg|gif|png)/i)
    end
  end
end
