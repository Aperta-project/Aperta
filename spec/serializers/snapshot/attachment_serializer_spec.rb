require "rails_helper"

describe Snapshot::AttachmentSerializer do
  describe "#snapshots?" do
    let(:attachment){ Attachment.new }

    it "returns true when it asked if it can snapshot an Attachment" do
      expect(described_class.snapshots?(attachment)).to be(true)
    end

    it "returns false otherwise" do
      expect(described_class.snapshots?(Object.new)).to be(false)
    end
  end
end
