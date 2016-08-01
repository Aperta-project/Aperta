require 'rails_helper'

describe DownloadAttachmentWorker, redis: true do
  let(:worker) { described_class.new }

  describe 'downloading attachments(s)' do
    let(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_task) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

    it "downloads the attachment" do
      with_aws_cassette('attachment') do
        worker.perform(attachment.id, url)

        # CarrierWave uploaders don't refresh with 'attachment.reload' so
        # find the record again to get any file-related updates
        expect(Attachment.find(attachment.id).filename).to eq('bill_ted1.jpg')
      end
    end
  end
end
