require "rails_helper"

describe Snapshot::EthicsTaskSerializer do
  let(:ethics_task) { FactoryGirl.create(:ethics_task)}

    it "serializes an ethics task" do
      snapshot = Snapshot::EthicsTaskSerializer.new(ethics_task).as_json

      expect(snapshot[0][:name]).to eq("human_subjects")
      expect(snapshot[0][:children][0][:name]).to eq("participants")
      expect(snapshot[1][:name]).to eq("animal_subjects")
      expect(snapshot[1][:children][0][:name]).to eq("field_permit")
    end
end
