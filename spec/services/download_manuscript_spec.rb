require 'spec_helper'

describe DownloadManuscript do
  def with_manuscript_cassette
    VCR.use_cassette('manuscript', :match_requests_on => [:method, VCR.request_matchers.uri_without_params(:Expires, :Signature)]) do
      yield
    end
  end

  let(:paper) { FactoryGirl.create(:paper) }
  let(:url) { "https://tahi-development.s3.amazonaws.com/temp/about_equations.docx" }

  it "downloads the attachment" do
    with_manuscript_cassette do
      DownloadManuscript.call(paper, url)
      expect(paper.manuscript.source.filename).to eq("about_equations.docx")
    end
  end

  it "updates the paper title" do
    with_manuscript_cassette do
      DownloadManuscript.call(paper, url)
      expect(paper.title).to eq("Technical Writing Information Sheets")
    end
  end
end
