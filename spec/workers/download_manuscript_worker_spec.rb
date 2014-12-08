require 'spec_helper'

describe DownloadManuscriptWorker, redis: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:url) { "https://tahi-test.s3.amazonaws.com/temp/about_equations.docx" }

  before do
    paper.create_manuscript!
  end

  it "downloads the attachment" do
    with_aws_cassette('manuscript') do
      DownloadManuscriptWorker.new.perform(paper.manuscript.id, url, { metadata: { paper_id: paper.id } })
      expect(paper.manuscript.reload.source.url).to match(%r{manuscript/source\.docx})
    end
  end
end
