class SupportingInformationFile < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper

  default_scope { order(:id) }

  mount_uploader :attachment, AdhocAttachmentUploader

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  def filename
    self[:attachment]
  end

  def alt
    if attachment.present?
      filename.split('.').first.gsub(/#{::File.extname(filename)}$/, '').humanize
    else
      "no attachment"
    end
  end

  def src
    attachment.url
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def detail_src
    if image?
      attachment.url(:detail)
    end
  end

  def preview_src
    if image?
      attachment.url(:preview)
    end
  end

  def image?
    if attachment.file
      IMAGE_TYPES.include? attachment.file.extension
    else
      false
    end
  end

  def insert_title
    self.title = "Title: #{attachment.filename}" if attachment.present?
  end
end
