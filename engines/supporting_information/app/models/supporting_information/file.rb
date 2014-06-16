module SupportingInformation
  class File < ActiveRecord::Base
    belongs_to :paper

    before_create :insert_title

    mount_uploader :attachment, SupportingInformation::AttachmentUploader

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

    private

    def insert_title
      self.title = "Title: #{attachment.filename}" if attachment.present?
    end
  end
end
