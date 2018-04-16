# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class AttachmentUploader < CarrierWave::Uploader::Base
  require 'mini_magick'
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage Rails.application.config.carrierwave_storage

  # image? is used both here and in Attachment
  def self.image?(file)
    if file.respond_to?('content_type')
      ["image/tiff", "application/postscript", "image/x-eps", "image/jpeg", "image/png", "image/gif"].include?(file.content_type)
    else
      !!(File.extname(file) =~ /(tif?f|eps|jpg|jpeg|gif|png)/i)
    end
  end

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
  rescue NoMethodError
    # See https://github.com/minimagick/minimagick/issues/379
    []
  end

  def colorspace_arguments
    return [] unless image.details['Colorspace']
    ['-colorspace', image.details['Colorspace']]
  rescue NoMethodError
    # See https://github.com/minimagick/minimagick/issues/379
    []
  end

  def format
    raise 'Cannot identify image format' unless image['%[base]']
    image['%[base]'].split('.').last
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
    self.class.image?(file)
  end
end
