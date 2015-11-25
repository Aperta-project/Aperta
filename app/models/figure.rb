class Figure < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper

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
    "/attachments/figures/#{id}" if done?
  end

  def detail_src
    "/attachments/figures/#{id}?version=detail" if done?
  end

  def preview_src
    "/attachments/figures/#{id}?version=preview" if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def apex_filename
    return filename unless self == paper.striking_image

    extension = filename.split('.').last
    "Strikingimage.#{extension}"
  end

  private

  def done?
    status == 'done'
  end
end
