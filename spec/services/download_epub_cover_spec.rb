require 'rails_helper'

describe DownloadEpubCover do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:url) { "https://tahi-test.s3.amazonaws.com/temp/500px-Jack_black.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('epub_cover_downloader') do
      DownloadEpubCover.call(journal, url)
      expect(journal.epub_cover.filename).to eq("500px-Jack_black.jpg")
    end
  end
end
