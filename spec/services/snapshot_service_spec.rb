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

  let(:things_to_snapshot) { [task_1, task_2, task_3] }
  let(:task_1) { FactoryGirl.create(:task) }
  let(:task_2) { FactoryGirl.create(:task) }
  let(:task_3) { FactoryGirl.create(:task) }

  before do
    registry.serialize task_1.class, with: ExampleSnapshotSerializer
  end

  describe '.snapshot_paper!' do
    let(:adhoc_attachment) do
      FactoryGirl.create(:adhoc_attachment, :with_task, paper: paper)
    end
    let(:figure) { FactoryGirl.create(:figure, paper: paper) }
    let(:question_attachment) do
      FactoryGirl.create(:question_attachment, paper: paper)
    end
    let(:si_file) do
      FactoryGirl.create(:supporting_information_file, paper: paper)
    end

    it 'snapshots the snapshottable tasks on the paper' do
      allow(paper).to receive(:snapshottable_tasks).and_return [task_1]
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.where(source_type: Task.sti_name).count }.by(1)
    end

    it 'snapshots the adhoc_attachments for the paper' do
      paper.adhoc_attachments.push adhoc_attachment
      registry.serialize AdhocAttachment, with: ExampleSnapshotSerializer
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.where(source: adhoc_attachment).count }.by(1)
    end

    it 'snapshots the figures for the paper' do
      paper.figures.push figure
      registry.serialize Figure, with: ExampleSnapshotSerializer
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.where(source: figure).count }.by(1)
    end

    it 'snapshots the question_attachments for the paper' do
      paper.question_attachments.push question_attachment
      registry.serialize QuestionAttachment, with: ExampleSnapshotSerializer
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.where(source: question_attachment).count }.by(1)
    end

    it 'snapshots the supporting_information_files for the paper' do
      paper.supporting_information_files.push si_file
      registry.serialize SupportingInformationFile, with: ExampleSnapshotSerializer
      expect do
        SnapshotService.snapshot_paper!(paper, registry)
      end.to change { Snapshot.where(source: si_file).count }.by(1)
    end
  end

  describe '#preview' do
    context "each snapshot" do
      let(:snapshots) { Snapshot.all.order('id') }

      it "sets the source of each snapshot to the thing snapshotted" do
        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].source).to eq(task_1)
        expect(snapshots[1].source).to eq(task_2)
        expect(snapshots[2].source).to eq(task_3)
      end

      it "sets the contents of each snapshot to the JSON returned by the snapshot serializer" do
        service.snapshot!(things_to_snapshot)

        expect(snapshots[0].contents).to eq(task_1.as_json.except("created_at", "updated_at"))
        expect(snapshots[1].contents).to eq(task_2.as_json.except("created_at", "updated_at"))
        expect(snapshots[2].contents).to eq(task_3.as_json.except("created_at", "updated_at"))
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
