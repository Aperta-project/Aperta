class SupportingInformationFile < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :paper

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

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
    return unless image?

    attachment.url(:detail)
  end

  def preview_src
    return unless image?

    attachment.url(:preview)
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
