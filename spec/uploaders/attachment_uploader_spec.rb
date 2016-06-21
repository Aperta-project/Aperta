require 'rails_helper'

describe AttachmentUploader do
  around do |example|
    AttachmentUploader.storage :file
    example.run
    AttachmentUploader.storage Rails.application.config.carrierwave_storage
  end

  describe '#store_dir' do
    let(:uploader) { described_class.new(model, :attachment) }

    context 'when the model has a cached s3_dir' do
      let(:model) { double("attachment_model", s3_dir: 'some/cached/path') }

      it 'returns the cached s3_dir' do
        expect(uploader.store_dir).to eq('some/cached/path')
      end
    end

    context 'when the model does not respond_to :s3_dir' do
      let(:paper) { double('paper', id: 11) }
      let(:model) { double('attachment_model', id: 99, paper: paper) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/#{model.class.to_s.underscore}/attachment/99"
      end
    end

    context 'when the model responds to :s3_dir, but has no s3_dir value' do
      let(:paper) { double('paper', id: 11) }
      let(:model) { double('attachment_model', id: 99, paper: paper) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/#{model.class.to_s.underscore}/attachment/99"
      end
    end
  end

  describe "image transcoding" do
    let(:paper) { double("paper", id: "1") }
    let(:model) { double("attachment_model", paper: paper, id: "0") }

    it "transcodes tiffs" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "transcodes eps" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'HTML5_Logo.eps')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "properly converts the colors of CMYK eps images" do
      def color_of_pixel(path, x, y)
        image = MiniMagick::Image.open(path)
        image.run_command(
          "convert",
          "#{image.path}[1x1+#{x}+#{y}]",
          "-depth",
          "8",
          "txt:"
        ).split("\n")[1]
      end

      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'cmyk-chart.eps')))
      MiniMagick::Image.open(uploader.preview.path)

      color = color_of_pixel(uploader.preview.path, 0, 0)
      expect(color).to include('#FFFFFF')
    end

    it "does not transcode other images" do
      uploader = AttachmentUploader.new(model, :file)
      expect(uploader).to_not receive(:set_srgb_colorspace)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("JPEG")
    end

    it "does not transcode documents" do
      uploader = AttachmentUploader.new(model, :file)
      expect(uploader).to_not receive(:set_srgb_colorspace)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
  end

  describe "image resizing" do
    let(:paper) { double("paper", id: "1") }
    let(:model) { double("attachment_model", paper: paper, id: "0") }

    it "resizes tiffs" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(220)
      expect(preview.height).to eq(220)
    end

    it "resizes eps" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'HTML5_Logo.eps')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(156)
      expect(preview.height).to eq(220)
    end

    it "resizes jpg" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "resizes png" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.png')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "resizes gif" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.gif')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.width).to eq(201)
      expect(preview.height).to eq(220)
    end

    it "does not resize documents" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
  end
end
