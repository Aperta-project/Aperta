# This class is responsible for downloading an image url and applying it to a
# Journal.
# In practice, this url will be from a temporary s3 bucket and this class will
# download the image to a permanent s3 location.
class DownloadJournalLogoWorker
  include Sidekiq::Worker

  def perform(journal_id, url)
    journal = Journal.find(journal_id)

    # forces carrierwave to download and process logo
    journal.update(remote_logo_url: url)
  end
end
