require 'rails_helper'

describe Attachment do
  describe "#image" do
    let(:attachment) { Attachment.new }

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
end
