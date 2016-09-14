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
    subject(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_task) }
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets title to file name'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! always keeps snapshotted files on s3'
    it_behaves_like 'attachment#download! manages resource tokens'
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
