class DownloadLogo
  def self.call journal, url
    journal.logo.download! url
    journal.save
    journal
  end
end
