require 'spec_helper'

describe AttachmentUploader do
  #include CarrierWave::Test::Matchers

  describe "#store_dir" do
    it "includes the paper id in the path" do
      paper = Paper.create! short_title: 'Uploader tests'
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/figure/attachment/#{figure.id}"
    end
  end
end
