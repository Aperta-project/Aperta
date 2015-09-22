require 'rails_helper'

describe DownloadFigureWorker do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:figure) { paper.figures.create }
  let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('figures') do
      DownloadFigureWorker.new.perform(figure.id, url)
      expect(figure.reload.attachment.file.path).to match(/bill_ted1\.jpg/)
    end
  end

  it "sets the figure title" do
    with_aws_cassette('figures') do
      DownloadFigureWorker.new.perform(figure.id, url)
      expect(figure.reload.title).to eq("bill_ted1.jpg")
    end
  end
end
