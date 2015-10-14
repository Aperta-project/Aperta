require 'rails_helper'

describe AdhocAttachmentUploader do

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
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "transcodes eps" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'cat.eps')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "does not transcode other images" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("JPEG")
    end

    it "does not transcode documents" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
  end

  describe "image resizing" do
    let(:paper) { double("paper", :id => "1") }
    let(:model) { double("attachment_model", :paper => paper, :id => "0") }

    before do
      AttachmentUploader.storage :file
    end

    after do
      AttachmentUploader.storage Rails.application.config.carrierwave_storage
    end

    it "resizes tiffs" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(220)
      expect(preview.height).to eq(220)
    end

    it "resizes eps" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'cat.eps')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(110)
      expect(preview.height).to eq(220)
    end

    it "resizes jpg" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "resizes png" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.png')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "resizes gif" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.gif')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "does not resize documents" do
      uploader = AdhocAttachmentUploader.new(model, :attachment)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
  end
end
