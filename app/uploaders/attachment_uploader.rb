class AttachmentUploader < CarrierWave::Uploader::Base
  require 'mini_magick'
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    model.try(:s3_dir) || generate_new_store_dir
  end

  def generate_new_store_dir
    "uploads/paper/#{model.paper_id}/attachment/#{model.id}/#{model.file_hash}"
  end

  version :detail, if: :image? do
    process convert_image: ["984x-1>"]

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  version :preview, if: :image? do
    process convert_image: ["475x220"]

    def full_filename(orig_file)
      full_name(orig_file)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def convert_image(size)
    extension = needs_transcoding?(file) ? ".png" : ".#{format}"
    temp_file = MiniMagick::Utilities.tempfile(extension)

    MiniMagick::Tool::Convert.new do |convert|
      convert.merge! density_arguments
      convert.merge! colorspace_arguments
      convert.merge! ["-resize", size]
      convert << current_path
      convert.merge! ["-colorspace", "sRGB"]
      convert << temp_file.path
    end

    FileUtils.cp(temp_file.path, current_path)
    file.content_type = MiniMagick::Image.open(current_path).mime_type
  end

  def image
    @image ||= MiniMagick::Image.open(current_path)
  end

  def full_name(orig_file)
    orig_file = model.filename unless orig_file
    if needs_transcoding?(orig_file)
      "#{version_name}_#{File.basename(orig_file, '.*')}.png"
    else
      "#{version_name}_#{orig_file}"
    end
  end

  def density_arguments
    return [] unless image.details['Total ink density']
    ['-density', image.details['Total ink density']]
  end

  def colorspace_arguments
    return [] unless image.details['Colorspace']
    ['-colorspace', image.details['Colorspace']]
  end

  def format
    fail 'Cannot identify image format' unless image.details['Base filename']
    image.details['Base filename'].split('.').last
  end

  def needs_transcoding?(file)
    return false unless file
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
