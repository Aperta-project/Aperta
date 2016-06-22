require 'rails_helper'

describe DownloadAdhocTaskAttachmentWorker, redis: true do
  let(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_task) }
  let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }
  let(:worker) { DownloadAdhocTaskAttachmentWorker.new }

  it "downloads the attachment" do
    with_aws_cassette('attachment') do
      worker.perform(attachment.id, url)
      expect(attachment.reload.file.path).to match(/bill_ted1\.jpg/)
    end
  end

  it "sets the attachment title" do
    with_aws_cassette('attachment') do
      worker.perform(attachment.id, url)
      expect(attachment.reload.title).to eq("bill_ted1.jpg")
    end
  end
end
