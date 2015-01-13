require 'rails_helper'

describe Figure, redis: true do
  let(:paper) { FactoryGirl.create :paper }
  let(:figure) {
    with_aws_cassette('figure') do
      paper.figures.create! attachment: File.open('spec/fixtures/yeti.tiff')
    end
  }
  describe "#access_details" do
    it "returns a hash with attachment src, filename, alt, and S3 URL" do
      expect(figure.access_details).to eq(filename: 'yeti.tiff',
                                          alt: 'Yeti',
                                          src: figure.attachment.url,
                                          id: figure.id)
    end
  end

  describe "acceptable content types" do
    it "accepts standard image types" do
      %w{gif jpg jpeg png tiff}.each do |type|
        expect(Figure.acceptable_content_type? "image/#{type}").to eq true
      end
    end

    it "rejects non-image types" do
      %w{doc docx pdf epub raw bmp}.each do |type|
        expect(Figure.acceptable_content_type? "image/#{type}").to eq false
      end
    end
  end

  describe "removing the attachment" do
    it "destroys the attachment on destroy" do
      # remove_attachment! is a built-in callback.
      # this spec exists so that we don't duplicate that behavior
      expect(figure).to receive(:remove_attachment!)
      figure.destroy
    end
  end
end
