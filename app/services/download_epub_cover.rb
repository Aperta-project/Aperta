class DownloadEpubCover
  def self.call journal, url
    journal.epub_cover.download! url
    journal.save
    journal
  end
end
