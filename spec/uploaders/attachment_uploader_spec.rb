require 'rails_helper'

describe AttachmentUploader do
  before do
    AttachmentUploader.enable_processing = true
  end

  describe "#store_dir" do
    it "includes the paper id in the path" do
      paper = FactoryGirl.create(:paper)
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      binding.pry
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/figure/attachment/#{figure.id}"
    end
  end
end
