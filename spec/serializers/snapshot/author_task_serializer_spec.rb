require "rails_helper"

describe Snapshot::AuthorTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:authors_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to eq(
        name: "authors-task",
        type: "properties",
        children: []
      )
    end

    context "and the task has authors" do
      let!(:author_bob) { FactoryGirl.create(:author, position: 2) }
      let!(:author_sally) { FactoryGirl.create(:author, position: 1) }

      let(:bobs_author_serializer) do
        double(
          "Snapshot::AuthorSerializer",
          as_json: { author: "bob's json here" }
        )
      end

      let(:sallys_author_serializer) do
        double(
          "Snapshot::AuthorSerializer",
          as_json: { author: "sally's json here" }
        )
      end

      before do
        task.authors = [author_bob, author_sally]
        allow(Snapshot::AuthorSerializer).to receive(:new).with(author_bob).and_return bobs_author_serializer
        allow(Snapshot::AuthorSerializer).to receive(:new).with(author_sally).and_return sallys_author_serializer
      end

      it "serializes each author(s) associated with the task in order by their respective position" do
        expect(serializer.as_json[:children]).to eq([
          { author: "sally's json here" },
          { author: "bob's json here" }
        ])
      end
    end
  end
end
