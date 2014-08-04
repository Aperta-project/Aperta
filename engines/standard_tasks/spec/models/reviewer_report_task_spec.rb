require 'spec_helper'

describe StandardTasks::ReviewerReportTask do
  describe "defaults" do
    subject(:task) { StandardTasks::ReviewerReportTask.new }
    specify { expect(task.title).to eq 'Reviewer Report' }
    specify { expect(task.role).to eq 'reviewer' }
  end

  describe "#destroy" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks }
    subject(:task) { FactoryGirl.create :reviewer_report_task, phase: paper.phases.first }

    before { create(:paper_role, :reviewer, user: task.assignee, paper: paper) }

    it "destroys the reviewer's paper role" do
      expect{ task.destroy }.to change{ PaperRole.count }.by(-1)
    end
  end
end
