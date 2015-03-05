require "rails_helper"

describe FiguresExtractor do
  let(:image_stream) { FileStringIO.new("sample-image.gif", File.open(Rails.root.join('spec', 'fixtures', '5x5-sample-image.gif'), 'rb').read) }
  let(:extractor) { FiguresExtractor.new("fake_stream") }
  let(:paper) { FactoryGirl.create(:paper) }

  describe "sync!" do
    before do
      allow(extractor).to receive(:images).and_return([image_stream])
    end

    it "creates a Figure for each image in the epub" do
      expect{ extractor.sync!(paper) }.to change(paper.figures, :count).by(1)
    end
  end
end
