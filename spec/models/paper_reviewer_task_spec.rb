require 'spec_helper'

describe PaperReviewerTask do
  describe "defaults" do
    subject(:task) { PaperReviewerTask.new }
    specify { expect(task.title).to eq 'Assign Reviewer' }
    specify { expect(task.role).to eq 'editor' }
  end

  describe "#paper_role" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:phase) { paper.task_manager.phases.first }

    context "when the role is not present" do
      it "initializes a new reviewer role" do
        role = PaperReviewerTask.new(phase: phase).paper_role
        expect(role.paper).to eq paper
        expect(role).to be_reviewer
      end
    end

    context "when the role is present" do
      it "returns the role" do
        role = PaperRole.create! paper: paper, reviewer: true
        expect(PaperReviewerTask.new(phase: phase).paper_role).to eq role
      end
    end
  end
end
