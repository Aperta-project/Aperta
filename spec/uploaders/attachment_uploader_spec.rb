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
    it "transcodes tiffs" do
      paper = FactoryGirl.create(:paper)
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      file = Rails.root.join('spec', 'fixtures', 'yeti.tiff')

      expect(uploader.needs_transcoding?(file)).to eq(true)
    end

    it "does not transcode other images" do
      paper = FactoryGirl.create(:paper)
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      file = Rails.root.join('spec', 'fixtures', 'yeti.jpg')

      expect(uploader.needs_transcoding?(file)).to eq(false)
    end

    it "does not transcode documents" do
      paper = FactoryGirl.create(:paper)
      figure = paper.figures.create!
      uploader = AttachmentUploader.new(figure, :attachment)
      file = Rails.root.join('spec', 'fixtures', 'about_turtles.docx')

      expect(uploader.needs_transcoding?(file)).to eq(false)
    end
  end
end
