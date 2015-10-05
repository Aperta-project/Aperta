require 'rails_helper'

describe AttachmentUploader do
  describe "#store_dir" do
    it "includes the paper id in the path" do
      paper = FactoryGirl.create(:paper)
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/figure/attachment/#{figure.id}"
    end
  end

  describe "#needs_transcoding?" do
    paper = FactoryGirl.create(:paper)
    figure = paper.figures.create!
    uploader = AttachmentUploader.new(figure, :attachment)
    expect(uploader.needs_transcoding?).to eq(false)
  end
end
