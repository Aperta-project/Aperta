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
    done? ? "attachments/figures/#{self.id}" : nil
  end

  def detail_src
    done? ? "attachments/figures/#{self.id}?version=detail" : nil
  end

  def preview_src
    done? ? "attachments/figures/#{self.id}?version=preview" : nil
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  private

  def done?
    status == 'done'
  end
end
