require 'spec_helper'

describe DownloadFigure do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:figure) { paper.figures.new }
  let(:url) { "http://tahi-development.s3.amazonaws.com/temp/bill_ted1.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('figures') do
      DownloadFigure.call(figure, url)
      expect(figure.attachment.filename).to eq("bill_ted1.jpg")
    end
  end

  it "sets the figure title" do
    with_aws_cassette('figures') do
      DownloadFigure.call(figure, url)
      expect(figure.title).to eq("bill_ted1.jpg")
    end
  end
end
