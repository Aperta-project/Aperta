require 'spec_helper'

describe Attachment do
  describe "#is_image" do
    let(:attachment) { Attachment.new }

    it "returns true if the file is of type image" do
      attachment.stub_chain("file.file.extension") {"jpg"}
      expect(attachment.is_image?).to eq(true)
    end

    it "returns false if the file is not of type image" do
      attachment.stub_chain("file.file.extension") {"pdf"}
      expect(attachment.is_image?).to eq(false)
    end
  end
end
