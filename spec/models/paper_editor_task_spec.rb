require 'spec_helper'

describe PaperEditorTask do
  describe "defaults" do
    subject(:task) { PaperEditorTask.new }
    specify { expect(task.title).to eq 'Assign Editor' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "#paper_role" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:phase) { paper.task_manager.phases.first }

    context "when the role is not present" do
      it "initializes a new editor role" do
        role = PaperEditorTask.new(phase: phase).paper_role
        expect(role.paper).to eq paper
        expect(role).to be_editor
      end
    end

    context "when the role is present" do
      it "returns the role" do
        role = PaperRole.create! paper: paper, editor: true
        expect(PaperEditorTask.new(phase: phase).paper_role).to eq role
      end
    end
  end
end
