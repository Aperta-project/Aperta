class Figure < ActiveRecord::Base
  belongs_to :paper

  mount_uploader :attachment, AttachmentUploader

  def access_details
    filename = self[:attachment]
    alt = filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize
    { filename: filename, alt: alt, id: id, src: attachment.url }
  end

end
