require 'rails_helper'

describe Attachment do
  subject(:attachment) { FactoryGirl.build(:attachment, :with_task) }

  describe "validations" do
    it "is valid" do
      expect(attachment.valid?).to be(true)
    end

    it "requires a :task" do
      attachment.task = nil
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

  describe "#docx" do
    it "is not an image" do
      attachment.update_attributes file: ::File.open('spec/fixtures/about_turtles.docx')
      expect(attachment.image?).to eq(false)
    end
  end
end
