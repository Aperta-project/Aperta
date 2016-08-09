require "rails_helper"

describe Snapshot::CompetingInterestsTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:competing_interests_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "competing-interests-task",
        type: "properties"
      )
    end

    context "serializing related nested questions" do
      it_behaves_like "snapshot serializes related nested questions", resource: :task
    end
  end
end
