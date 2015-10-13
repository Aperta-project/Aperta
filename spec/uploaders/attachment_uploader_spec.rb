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

  describe "image transcoding" do
    let(:paper) { double("paper", :id => "1") }
    let(:model) { double("attachment_model", :paper => paper, :id => "0") }

    before do
      AttachmentUploader.storage :file
    end

    after do
      AttachmentUploader.storage Rails.application.config.carrierwave_storage
    end

    it "transcodes tiffs" do
      uploader = AttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "transcodes eps" do
      uploader = AttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'cat.eps')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "does not transcode other images" do
      uploader = AttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("JPEG")
    end

    it "does not transcode documents" do
      uploader = AttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end

  end
end
