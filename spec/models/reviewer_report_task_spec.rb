require 'spec_helper'

describe ReviewerReportTask do
  describe "defaults" do
    subject(:task) { ReviewerReportTask.new }
    specify { expect(task.title).to eq 'Reviewer Report' }
    specify { expect(task.role).to eq 'reviewer' }
  end

  describe "#destroy" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks }
    subject(:task) { FactoryGirl.create :reviewer_report_task, phase: paper.phases.first }

    before { PaperRole.create!(reviewer: true, user: task.assignee, paper: paper) }

    it "destroys the reviewer's paper role" do
      expect{ task.destroy }.to change{ PaperRole.count }.by(-1)
    end
  end
end
