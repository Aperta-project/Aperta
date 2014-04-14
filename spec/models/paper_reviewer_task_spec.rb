require 'spec_helper'

describe PaperReviewerTask do
  describe "defaults" do
    subject(:task) { PaperReviewerTask.new }
    specify { expect(task.title).to eq 'Assign Reviewers' }
    specify { expect(task.role).to eq 'editor' }
  end

  let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
  let(:phase) { paper.task_manager.phases.first }

  let(:albert) { FactoryGirl.create :user, :admin }
  let(:neil) { FactoryGirl.create :user }

  describe "#reviewer_ids=" do
    let(:task) { PaperReviewerTask.create!(phase: phase) }

    it "creates reviewer paper roles only for new ids" do
      PaperRole.create! paper: paper, reviewer: true, user: albert
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.where(paper: paper, reviewer: true, user: neil)).not_to be_empty
    end

    it "creates reviewer report tasks only for new ids" do
      task.reviewer_ids = [neil.id.to_s]
      phase = paper.task_manager.phases.where(name: 'Get Reviews').first
      expect(ReviewerReportTask.where(assignee: neil, phase: phase)).to be_present
    end

    it "deletes reviewer report tasks of the ids not specified" do
      phase = paper.task_manager.phases.where(name: 'Get Reviews').first
      PaperRole.create! paper: paper, reviewer: true, user: albert
      ReviewerReportTask.create! assignee: albert, phase: phase
      task.reviewer_ids = [neil.id.to_s]
      expect(ReviewerReportTask.where(assignee: albert, phase: phase)).to be_empty
    end

    it "deletes paper roles not present in the specified user_id" do
      PaperRole.create! paper: paper, reviewer: true, user: albert
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.where(paper: paper, reviewer: true, user: albert)).to be_empty
    end
  end

  describe "#reviewer_ids" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:task) { PaperReviewerTask.create! phase: paper.task_manager.phases.first }
    let (:reviewer1) { FactoryGirl.create :user }
    let (:reviewer2) { FactoryGirl.create :user }

    before do
      PaperRole.create! paper: paper, reviewer: true, user: reviewer1
      PaperRole.create! paper: paper, reviewer: true, user: reviewer2
    end

    it "returns the current reviewer IDs" do
      expect(task.reviewer_ids).to match_array [reviewer1.id, reviewer2.id]
    end
  end
end
