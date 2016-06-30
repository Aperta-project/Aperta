RSpec.shared_examples_for 'attachment#download! sets the file_hash' do
  describe 'the file_hash' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to a SHA256 hexdigest of the file contents' do
      fixture_file = Rails.root.join('spec/fixtures', File.basename(url))
      unless File.exists?(fixture_file)
        fail <<-ERROR.strip_heredoc
          There is no local fixture file with a name matching the file in the
          provided url:

          url provided: #{url}
          looking for file: #{fixture_file}

          A fixture file needs to exist in order to determine that the file_hash
          is set correctly.
        ERROR
      end

      expect do
        subject.download!(url)
      end.to change {
        subject.file_hash
      }.to Digest::SHA256.hexdigest(IO.read(fixture_file))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! stores the file' do
  describe 'the file' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is downloaded from the given URL' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.file.path }.to match(File.basename(url))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! caches the s3 store_dir' do
  describe 'the s3 store_dir' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is cached' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.s3_dir }.to subject.file.store_dir
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets title to file name' do
  describe 'sets the title' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to the file name' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.title }.to eq(File.basename(url))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets the status' do
  describe 'setting the status' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to done' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.status }.to self.described_class::STATUS_DONE
    end
  end
end

RSpec.shared_examples_for 'attachment#download! knows when to keep and remove s3 files' do
  describe 'previously uploaded s3 file' do
    let(:url_1) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }
    let(:url_2) { 'http://tahi-test.s3.amazonaws.com/temp/frank_sally.jpg' }

    before do
      subject.download!(url_1)
    end

    it 'is removed when it has never been snapshotted' do
      expect(subject).to receive(:remove_previously_stored_file)
      subject.download!(url_2)
    end

    it 'is not removed when it has been snapshotted' do
      snapshot = FactoryGirl.create(:snapshot, source: subject)
      expect(subject).to_not receive(:remove_previously_stored_file)
      url = 'http://tahi-test.s3.amazonaws.com/temp/frank_sally.jpg'
      subject.download!(url_2)
    end
  end
end

RSpec.shared_examples_for 'standard attachment image transcoding' do
  around do |example|
    # Do not change this to described_class or the subclass. CarrierWave
    # really wants this configured on the base uploader
    AttachmentUploader.storage :file
    example.run
    AttachmentUploader.storage Rails.application.config.carrierwave_storage
  end

  describe "image transcoding" do
    let(:model) { double("attachment_model", paper_id: 99, id: 1) }

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

RSpec.shared_examples_for 'standard attachment image resizing' do
  around do |example|
    # Do not change this to described_class or the subclass. CarrierWave
    # really wants this configured on the base uploader
    AttachmentUploader.storage :file
    example.run
    AttachmentUploader.storage Rails.application.config.carrierwave_storage
  end

  describe "image resizing" do
    let(:model) { double("attachment_model", paper_id: 99, id: 1) }

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
