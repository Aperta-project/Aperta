class Figure < ActiveRecord::Base
  belongs_to :paper

  mount_uploader :attachment, AttachmentUploader

  def filename
    self[:attachment]
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize
  end

  def src
    attachment.url
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

end
