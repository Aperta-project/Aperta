class Figure < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper

  # paper.figures are being returned in reverse-id order
  # Why the hell is that happening?
  default_scope { order(:id) }


  mount_uploader :attachment, AttachmentUploader

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def filename
    self[:attachment]
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize if filename.present?
  end

  def src
    attachment.url
  end

  def detail_src
    attachment.url(:detail)
  end

  def preview_src
    attachment.url(:preview)
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end
end
