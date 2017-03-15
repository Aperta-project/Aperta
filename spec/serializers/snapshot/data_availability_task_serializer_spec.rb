require "rails_helper"

describe Snapshot::DataAvailabilityTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:data_availability_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "data-availability-task",
        type: "properties"
      )
    end

    it_behaves_like "snapshot serializes related answers as nested questions", resource: :task
  end
end
