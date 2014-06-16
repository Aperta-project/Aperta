module SupportingInformation
  class DownloadSupportingInfo
    def self.call supporting_info, url
      supporting_info.attachment.download! url
      supporting_info.save
      supporting_info
    end
  end
end
