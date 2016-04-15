require "rails_helper"

describe Snapshot::BaseSerializer do
  class Snapshot::TestSerializer < Snapshot::BaseSerializer
    private

    def snapshot_properties
      [{ properties: "here" }]
    end

    def snapshot_nested_questions
      [{ questions: "here" }]
    end
  end

  describe "snapshot ordering of children" do
    subject(:serializer) { Snapshot::TestSerializer.new(model) }
    let(:model) { OpenStruct.new(nested_questions: [], id: 1) }

    it "snapshots nested questions first, then id, then other properties" do
      expect(serializer.as_json[:children]).to eq([
        { questions: "here" },
        { name: "id", type: "integer", value: 1 },
        { properties: "here" }
      ])
    end
  end
end
