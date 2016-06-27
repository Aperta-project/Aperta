require 'rails_helper'

describe AdhocAttachment do
  subject(:attachment) do
    FactoryGirl.build(:adhoc_attachment, :with_task)
  end

  describe "validations" do
    it "is valid" do
      expect(attachment.valid?).to be(true)
    end

    it "requires an :owner" do
      attachment.owner = nil
      expect(attachment.valid?).to be(false)
    end
  end

  describe '#download!', vcr: { cassette_name: 'attachment' } do
    let(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_task) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

    it 'downloads the file at the given URL, caches the s3 store_dir' do
      attachment.download!(url)
      attachment.reload
      expect(attachment.file.path).to match(/bill_ted1\.jpg/)

      expect(attachment.file.store_dir).to be
      expect(attachment.s3_dir).to eq(attachment.file.store_dir)
    end

    it 'sets the title and status' do
      attachment.download!(url)
      attachment.reload
      expect(attachment.title).to eq('bill_ted1.jpg')
      expect(attachment.status).to eq(self.described_class::STATUS_DONE)
    end
  end

  describe "#image" do
    it "returns true if the file is of type image" do
      file = OpenStruct.new(file: OpenStruct.new(extension: "jpg"))
      expect(attachment).to receive(:file).twice.and_return(file)
      expect(attachment.image?).to eq(true)
    end

    it "returns false if the file is not of type image" do
      file = OpenStruct.new(file: OpenStruct.new(extension: "pdf"))
      expect(attachment).to receive(:file).twice.and_return(file)
      expect(attachment.image?).to eq(false)
    end
  end

  describe "#filename" do
    it "returns the proper filename" do
      attachment.update_attributes file: ::File.open('spec/fixtures/yeti.tiff')
      expect(attachment.filename).to eq "yeti.tiff"
    end
  end
end
