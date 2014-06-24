module SupportingInformation
  class File < ActiveRecord::Base
    include EventStreamNotifier

    belongs_to :paper

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

    def insert_title
      self.title = "Title: #{attachment.filename}" if attachment.present?
    end

    def notifier_payload
      { id: id, paper_id: paper.id }
    end
  end
end
