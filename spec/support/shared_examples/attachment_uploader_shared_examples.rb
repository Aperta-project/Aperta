# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

RSpec.shared_examples_for 'AttachmentUploader: standard attachment image transcoding' do
  around do |example|
    # Do not change this to described_class or the subclass. CarrierWave
    # really wants this configured on the base uploader
    AttachmentUploader.storage :file
    example.run
    AttachmentUploader.storage :fog
  end

  describe "image transcoding" do
    let(:model) { FactoryGirl.build_stubbed(:attachment, paper_id: 99) }

    it "transcodes tiffs" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "transcodes TIFFS" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti2.TIFF')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("PNG")
    end

    it "does not transcode jpg" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("JPEG")
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

    it "works around bugs in mini_magick" do
      # See https://github.com/minimagick/minimagick/issues/379
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'metadata_newline.tiff')))
      preview = MiniMagick::Image.open(uploader.preview.path)
      expect(preview.type).to eq("PNG")
    end

    it "does not transcode other images" do
      uploader = AttachmentUploader.new(model, :file)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'yeti.jpg')))
      preview = MiniMagick::Image.open(uploader.preview.path)

      expect(preview.type).to eq("JPEG")
    end

    it "does not transcode documents" do
      uploader = AttachmentUploader.new(model, :file)
      expect(uploader).to_not receive(:convert_image)
      uploader.store!(File.open(Rails.root.join('spec', 'fixtures', 'about_turtles.docx')))

      expect(uploader.content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
  end
end

RSpec.shared_examples_for 'AttachmentUploader: standard attachment image resizing' do
  around do |example|
    # Do not change this to described_class or the subclass. CarrierWave
    # really wants this configured on the base uploader
    AttachmentUploader.storage :file
    example.run
    AttachmentUploader.storage :fog
  end

  describe "image resizing" do
    let(:model) { FactoryGirl.build_stubbed(:attachment, paper_id: 99) }

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
