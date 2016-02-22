require 'rails_helper'

describe DownloadManuscriptWorker, redis: true do
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator)
  end
  let(:url) { 'https://example.com/temp/about_equations.docx' }

  before do
    VCR.turn_off!
    versioned_text_id = paper.latest_version.id
    s3_url = "https://tahi-test.s3-us-west-1.amazonaws.com/uploads/\
versioned_text/#{versioned_text_id}/about_equations.docx"
    @docx_req = stub_request(:get, url).to_return(body: 'foo')
    @s3_req = stub_request(:get, s3_url)
      .with(query: hash_including)
      .to_return(body: 'foo')
    @ihat_status_req = stub_request(:post, 'http://ihat.example.com/jobs')
      .with(body: /.*/)
      .to_return(body: { job: { state: 'processing', options: {} } }.to_json)
  end

  after do
    VCR.turn_on!
  end

  it 'downloads the attachment' do
    DownloadManuscriptWorker.new.perform(paper.id, url, 'http://localhost/callback',
                                         foo: 'bar')
    expect(@docx_req).to have_been_requested
    expect(@s3_req).to have_been_requested
    expect(@ihat_status_req).to have_been_made.at_least_once
  end
end
