require 'rails_helper'

describe DownloadManuscriptWorker, redis: true do
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:url) { 'http://tahi.example.com/paper.docx' }

  describe '.download_manuscript' do
    before do
      allow(paper).to receive(:update_attribute)
    end

    it 'queues up a job to download the manuscript' do
      expect(DownloadManuscriptWorker).to receive(:perform_async).with(paper.id, url, user.id)
      described_class.download_manuscript(paper, url, user)
    end

    it "does not retry" do
      worker = described_class.new
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end

    context 'when the URL is blank' do
      it 'raises an exception' do
        expect do
          described_class.download_manuscript(paper, nil, user)
        end.to raise_error(ArgumentError, "Url must be provided (received a blank value)")
      end
    end

    it 'marks the paper as processing' do
      expect(paper).to receive(:update_attribute).with(:processing, true)
      described_class.download_manuscript(paper, url, user)
    end
  end

  describe '#perform' do
    before do
      allow(User).to receive(:find).with(user.id).and_return user
      allow(Paper).to receive(:find).with(paper.id).and_return paper
    end

    it 'downloads a manuscript with a user' do
      expect(paper).to receive(:download_manuscript!).with(url, uploaded_by: user)
      described_class.new.perform(paper.id, url, user.id)
    end

    it 'downloads a manuscript with a blank user' do
      expect(paper).to receive(:download_manuscript!).with(url, uploaded_by: nil)
      described_class.new.perform(paper.id, url, nil)
    end
  end

  describe 'checks for duplicates file' do
    let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
    let(:paper_with_file) { create :paper, :ready_for_export }
    let(:file_bytes) { File.open(Rails.root.join('spec/fixtures/about_turtles.docx')).read }
    before do
      VCR.turn_off!
      stub_request(:get, url).to_return(body: file_bytes)
    end

    after do
      VCR.turn_on!
    end

    it 'displays a message if a duplicated file is uploaded' do
      Sidekiq::Testing.inline! do
        paper = paper_with_file
        user = paper.creator
        paper.file.update(file_hash: Digest::SHA256.hexdigest(file_bytes))
        expect(pusher_channel).to receive_push(
          payload: hash_including(
            messageType: 'alert'
          ),
          down: 'user',
          on: 'flashMessage'
        )
        DownloadManuscriptWorker.download_manuscript(paper, url, user)
      end
    end

    it 'doesn\'t displays a message if a duplicated file is uploaded' do
      Sidekiq::Testing.inline! do
        paper = paper_with_file
        user = paper.creator
        expect(pusher_channel).to_not receive_push(payload: hash_including(:messageType, :message), down: 'user', on: 'flashMessage')
        DownloadManuscriptWorker.download_manuscript(paper, url, user)
      end
    end
  end
end
