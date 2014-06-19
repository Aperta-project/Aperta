require 'spec_helper'

describe DownloadManuscript do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:url) { "https://tahi-development.s3.amazonaws.com/temp/about_equations.docx" }

  it "downloads the attachment" do
    with_aws_cassette('manuscript') do
      manuscript = DownloadManuscript.enqueue(paper.id, url)
      expect(manuscript.source.filename).to be_present
    end
  end

  it "updates the paper title" do
    with_aws_cassette('manuscript') do
      DownloadManuscript.enqueue(paper.id, url)
      expect(paper.reload.title).to eq("Technical Writing Information Sheets")
    end
  end
end
