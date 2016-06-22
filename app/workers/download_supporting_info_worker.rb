class DownloadSupportingInfoWorker
  include Sidekiq::Worker

  def perform supporting_info_id, url
    supporting_info = SupportingInformationFile.find supporting_info_id
    supporting_info.download!(url)
  end
end
