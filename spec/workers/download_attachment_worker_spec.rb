require 'rails_helper'

describe DownloadAttachmentWorker, redis: true do
  let(:worker) { described_class.new }

  describe 'downloading attachments(s)' do
    let(:attachment) { FactoryGirl.build_stubbed(:attachment) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }
    let(:user) { FactoryGirl.build_stubbed(:user) }

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
end
