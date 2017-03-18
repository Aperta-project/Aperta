require 'rails_helper'

describe DownloadJournalLogoWorker do
  subject(:worker) { DownloadJournalLogoWorker.new }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:url) { "http://example.com/new-image.png" }

  before do
    allow(Journal).to receive(:find)
      .with(journal.id).and_return journal
  end

  it 'downloads and stores the new logo on the journal' do
    expect(journal).to receive(:update).with(remote_logo_url: url)
    worker.perform(journal.id, url)
  end
end
