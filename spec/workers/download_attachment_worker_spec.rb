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
        expect(described_class).to receive(:perform_async)
          .with(attachment.id, url, user.id)
        described_class.download_attachment(attachment, url, user)
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
  end
end
