require 'rails_helper'
require 'webmock/rspec'

describe DownloadManuscriptWorker, redis: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:url) { 'https://example.com/temp/about_equations.docx' }

  before do
    VCR.turn_off!
    @requests = []
    @requests << stub_request(:get, url).to_return(body: 'foo')
    @requests << stub_request(:get, 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/versioned_text/1/about_equations.docx')
      .with(query: hash_including)
      .to_return(body: 'foo')
    @requests << stub_request(:post, 'http://ihat.example.com/jobs')
      .with(body: /.*/)
      .to_return(body: { job: { state: 'processing', options: {} } }.to_json)
  end

  after do
    VCR.turn_on!
    @requests.each do |req|
      expect(req).to have_been_requested
    end
  end

  it 'downloads the attachment' do
    DownloadManuscriptWorker.new.perform(paper.id, url, 'http://localhost/callback',
                                         foo: 'bar')
    expect(WebMock).to have_requested(:get, url)
  end
end
