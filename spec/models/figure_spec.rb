require 'spec_helper'

describe Figure do
  describe "#access_details" do
    it "returns a hash with attachment src, filename, alt, and S3 URL" do
      paper = Paper.create! short_title: 'Testing figures', journal: Journal.create!
      figure = paper.figures.create! attachment: File.open('spec/fixtures/yeti.tiff')
      expect(figure.access_details).to eq(filename: 'yeti.tiff',
                                          alt: 'Yeti',
                                          src: figure.attachment.url,
                                          id: figure.id)
    end
  end
end
