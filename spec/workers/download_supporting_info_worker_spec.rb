require 'rails_helper'

describe DownloadSupportingInfoWorker, redis: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:file) { paper.supporting_information_files.create }
  let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('supporting_info_file') do
      DownloadSupportingInfoWorker.new.perform(file.id, url)
      expect(file.reload.attachment.file.path).to match(/bill_ted1\.jpg/)
    end
  end

  it "sets the figure title" do
    with_aws_cassette('supporting_info_file') do
      DownloadSupportingInfoWorker.new.perform(file.id, url)
      expect(file.reload.title).to match(/bill_ted1\.jpg/)
    end
  end

  context "with a .docx file" do
    let(:docx_url) { "https://s3-us-west-1.amazonaws.com/aperta-test/about_turtles.docx" }

    it "does not try to convert it" do
      with_aws_cassette('supporting_info_file2') do
        DownloadSupportingInfoWorker.new.perform(file.id, docx_url)
        expect(file).to eq nil
      end
    end
  end
end
