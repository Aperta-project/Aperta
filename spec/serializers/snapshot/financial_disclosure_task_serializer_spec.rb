require "rails_helper"

describe Snapshot::FinancialDisclosureTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) {FactoryGirl.create(:financial_disclosure_task)}

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "financial-disclosure-task",
        type: "properties"
      )
    end

    context "and the task has funders" do
      let!(:funder_bob) { FactoryGirl.create(:funder, id: 2) }
      let!(:funder_sally) { FactoryGirl.create(:funder, id: 1) }

      let(:bobs_funder_serializer) do
        double(
          "Snapshot::FunderSerializer",
          as_json: { funder: "bob's json here" }
        )
      end

      let(:sallys_funder_serializer) do
        double(
          "Snapshot::FunderSerializer",
          as_json: { funder: "sally's json here" }
        )
      end

      before do
        task.funders = [funder_bob, funder_sally]
        allow(Snapshot::FunderSerializer).to receive(:new).with(funder_bob).and_return bobs_funder_serializer
        allow(Snapshot::FunderSerializer).to receive(:new).with(funder_sally).and_return sallys_funder_serializer
      end

      it "serializes each funders(s) associated with the task in order by their respective id" do
        expect(serializer.as_json[:children]).to include(
          { funder: "sally's json here" },
          { funder: "bob's json here" }
        )
      end
    end

    it_behaves_like "snapshot serializes related nested questions", resource: :task
  end
end
