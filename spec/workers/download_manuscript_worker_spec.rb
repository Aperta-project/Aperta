require 'spec_helper'

describe DownloadManuscriptWorker do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:url) { "https://tahi-test.s3.amazonaws.com/temp/about_equations.docx" }

  before do
    paper.create_manuscript!
  end

  it "downloads the attachment" do
    with_aws_cassette('manuscript') do
      DownloadManuscriptWorker.new.perform(paper.manuscript.id, url)
      expect(paper.manuscript.reload.source.url).to match(%r{manuscript/source\.docx})
    end
  end

  it "updates the paper title" do
    with_aws_cassette('manuscript') do
      DownloadManuscriptWorker.new.perform(paper.manuscript.id, url)
      expect(paper.reload.title).to eq("Technical Writing Information Sheets")
    end
  end
end
