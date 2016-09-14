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
end
