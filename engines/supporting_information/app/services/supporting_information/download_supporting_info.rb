module SupportingInformation
  class DownloadSupportingInfo < ActiveJob::Base
    queue_as :process_supporting_infos

    def perform supporting_info_id, url
      supporting_info = ::SupportingInformation::File.find supporting_info_id
      supporting_info.attachment.download! url
      supporting_info.insert_title
      supporting_info.status = "done"
      supporting_info.save!
    end
  end
end
