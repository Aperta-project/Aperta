require 'rails_helper'

describe DownloadFigureWorker, redis: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:figure) { paper.figures.create }
  let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

  it "downloads the attachment" do
    with_aws_cassette('figures') do
      DownloadFigureWorker.new.perform(figure.id, url)
      expect(figure.reload.attachment.file.path).to match(/bill_ted1\.jpg/)
    end
  end

  context "The uploaded file name finds a figure" do
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/fig-1.jpg" }
    it "sets the figure title and rank" do
      with_aws_cassette('labeled_figures') do
        DownloadFigureWorker.new.perform(figure.id, url)
        expect(figure.reload.title).to eq("Fig. 1")
        expect(figure.reload.rank).to eq(1)
      end
    end
  end

  context "The uploaded file name does not find a figure" do
    it "titles the figure as Unlabeled and sets rank to 0" do
      with_aws_cassette('figures') do
        DownloadFigureWorker.new.perform(figure.id, url)
        expect(figure.reload.title).to eq("Unlabeled")
        expect(figure.reload.rank).to eq(0)
      end
    end
  end
end
