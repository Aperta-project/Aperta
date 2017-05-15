require 'rails_helper'

describe DownloadAttachmentWorker, redis: true do
  let(:worker) { described_class.new }

  describe 'downloading attachments(s)' do
    let(:attachment) { FactoryGirl.build_stubbed(:attachment) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }
    let(:user) { FactoryGirl.build_stubbed(:user) }

    describe ".download_attachment" do
      it "sets the attachment to processing and queues up sidekiq job" do
        expect(attachment).to receive(:update_attribute)
          .with(:status, Attachment::STATUS_PROCESSING)
        described_class.download_attachment(attachment, url, user)
        expect(DownloadAttachmentWorker).to have_queued_job(attachment.id, url, user.id)
      end
    end

    describe ".reprocess" do
      it "short circuits if `pending_url` is nil" do
        expect(attachment).to receive(:pending_url).and_return(nil)
        described_class.reprocess(attachment, user)
        expect(DownloadAttachmentWorker).to have_empty_queue
      end

      it "creates a download attachment process" do
        allow(attachment).to receive(:pending_url).and_return(url)
        expect(attachment).to receive(:update_attribute).with(:status, Attachment::STATUS_PROCESSING)
        described_class.reprocess(attachment, user)
        expect(DownloadAttachmentWorker).to have_queued_job(attachment.id, url, user.id)
      end
    end

    context "with a user and attachment" do
      before do
        allow(User).to receive(:find)
          .with(user.id).and_return user
        allow(Attachment).to receive(:find)
          .with(attachment.id).and_return attachment
      end

      it "downloads the attachment" do
        expect(attachment).to receive(:download!)
          .with(url, uploaded_by: user)
        worker.perform(attachment.id, url, user.id)
      end
    end

    it "rescues ActiveRecord::RecordNotFound" do
      expect { worker.perform(2, "fake url", 50) }.to_not raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not retry" do
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end
  end
end
