require 'rails_helper'

describe DownloadQuestionAttachmentWorker do
  let(:question_attachment) { FactoryGirl.create(:question_attachment) }
  let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('question_attachment') do
      DownloadQuestionAttachmentWorker.new.perform(question_attachment.id, url)
      expect(question_attachment.reload.attachment.file.path).to match(/bill_ted1\.jpg/)
      expect(question_attachment.status).to eq("done")
    end
  end
end
