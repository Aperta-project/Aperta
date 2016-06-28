require "rails_helper"

describe SnapshotService do
  class ExampleSnapshotSerializer
    def initialize(thing_to_snapshot)
      @thing_to_snapshot = thing_to_snapshot
    end

    def as_json
      @thing_to_snapshot.as_json.except("created_at", "updated_at")
    end
  end

  subject(:service) { described_class.new(paper, registry) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:registry) { SnapshotService::Registry.new }

  let(:things_to_snapshot) { [fake_thing_1, fake_thing_2, fake_thing_3] }
  let(:fake_thing_1) { FactoryGirl.create(:task) }
  let(:fake_thing_2) { FactoryGirl.create(:task) }
  let(:fake_thing_3) { FactoryGirl.create(:task) }

  before do
    registry.serialize fake_thing_1.class, with: ExampleSnapshotSerializer
  end

  describe '.snapshot_paper!' do
    before do
      allow(paper).to receive(:snapshottable_tasks)
        .and_return [fake_thing_1]
    end

    it 'snapshots the paper' do
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.count }
    end
  end

  describe '#preview' do
    context "each snapshot" do
      let(:snapshots) { Snapshot.all.order('id') }

      it "sets the source of each snapshot to the thing snapshotted" do
        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].source).to eq(fake_thing_1)
        expect(snapshots[1].source).to eq(fake_thing_2)
        expect(snapshots[2].source).to eq(fake_thing_3)
      end

      it "sets the contents of each snapshot to the JSON returned by the snapshot serializer" do
        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].contents).to eq(fake_thing_1.as_json.except("created_at", "updated_at"))
        expect(snapshots[1].contents).to eq(fake_thing_2.as_json.except("created_at", "updated_at"))
        expect(snapshots[2].contents).to eq(fake_thing_3.as_json.except("created_at", "updated_at"))
      end

      it "ties each snapshot back to the paper" do
        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].paper).to eq(paper)
        expect(snapshots[1].paper).to eq(paper)
        expect(snapshots[2].paper).to eq(paper)
      end

      it "saves the major and minor version of the paper" do
        allow(paper).to receive(:major_version).and_return 4
        allow(paper).to receive(:minor_version).and_return 1

        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].major_version).to eq(4)
        expect(snapshots[0].minor_version).to eq(1)

        expect(snapshots[1].major_version).to eq(4)
        expect(snapshots[1].minor_version).to eq(1)

        expect(snapshots[2].major_version).to eq(4)
        expect(snapshots[2].minor_version).to eq(1)
      end
    end
  end

  describe '#snapshot!' do
    it 'creates a snapshot for each thing provided' do
      expect do
        service.snapshot!(things_to_snapshot)
      end.to change(Snapshot, :count).by(things_to_snapshot.length)
    end
  end
end
