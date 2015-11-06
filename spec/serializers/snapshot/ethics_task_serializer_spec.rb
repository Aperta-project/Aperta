require "rails_helper"

describe Snapshot::EthicsTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:ethics_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "ethics-task",
        type: "properties"
      )
    end

    context "serializing related nested questions" do
      include_examples "snapshot serializes related nested questions", resource: :task
    end
  end
end
