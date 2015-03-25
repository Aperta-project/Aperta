module TahiSupportingInformation
  class DownloadSupportingInfoWorker
    include Sidekiq::Worker

    def perform supporting_info_id, url
      supporting_info = ::TahiSupportingInformation::File.find supporting_info_id
      supporting_info.attachment.download! url
      supporting_info.insert_title
      supporting_info.status = "done"
      supporting_info.save!
    end
  end
end
