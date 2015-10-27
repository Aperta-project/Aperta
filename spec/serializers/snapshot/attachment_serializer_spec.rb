require "rails_helper"

describe Snapshot::AttachmentSerializer do
  subject(:serializer) { described_class.new(attachment) }

  let(:attachment) do
    FactoryGirl.create(
      :attachment,
      :with_task,
      file: File.open(Rails.root.join("spec/fixtures/yeti.jpg")),
      caption: "Hooray!",
      status: "processing",
      title: "Snowman"
    )
  end

  describe "#as_json" do
    it "serializes the attachment to JSON" do
      expect(serializer.as_json).to eq([
        { name: "file", type: "text", value: "yeti.jpg" },
        { name: "title", type: "text", value: "Snowman" },
        { name: "caption", type: "text", value: "Hooray!" },
        { name: "status", type: "text", value: "processing" }
      ])
    end
  end
end
