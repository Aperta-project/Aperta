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

  # describe "#transcoding" do
  #   it "won't transcode non-images" do
  #     paper = FactoryGirl.create(:paper)
  #     file = paper.supporting_information_files.create!
  #     uploader = AttachmentUploader.new(file, :attachment)
  #     #TODOMPM
  #     binding.pry
  #   end
  # end
end
