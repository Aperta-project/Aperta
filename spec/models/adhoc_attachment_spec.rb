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
