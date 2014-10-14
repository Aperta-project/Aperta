require 'spec_helper'

describe StandardTasks::PaperReviewerTask do
  describe "defaults" do
    subject(:task) { StandardTasks::PaperReviewerTask.new }
    specify { expect(task.title).to eq 'Assign Reviewers' }
    specify { expect(task.role).to eq 'editor' }
  end

  let!(:journal) do
    journal = create :journal
    journal.manuscript_manager_templates.destroy_all
    mmt = create :manuscript_manager_template, journal: journal
    mmt.phase_templates.create! name: "Collect Info"
    mmt.phase_templates.create! name: "Get Reviews"
    journal
  end

  let(:paper) { create :paper, :with_tasks, journal: journal }
  let(:phase) { paper.phases.first }

  let(:albert) { create :user, :admin }
  let(:neil) { create :user }

  describe "#reviewer_ids=" do
    let(:task) { StandardTasks::PaperReviewerTask.create!(phase: paper.phases.first) }

    it "creates reviewer paper roles only for new ids" do
      create(:paper_role, :reviewer, paper: paper, user: albert)
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.reviewers.where(paper: paper, user: neil)).not_to be_empty
    end

    it "creates reviewer report tasks only for new ids" do
      task.reviewer_ids = [neil.id.to_s]
      phase = paper.phases.where(name: 'Get Reviews').first
      expect(StandardTasks::ReviewerReportTask.where(phase: phase)).to be_present
    end

    it "deletes reviewer report tasks of the ids not specified" do
      phase = paper.phases.where(name: 'Get Reviews').first
      create(:paper_role, :reviewer, paper: paper, user: albert)
      StandardTasks::ReviewerReportTask.create!(phase: phase)
      task.reviewer_ids = [neil.id.to_s]
      expect(StandardTasks::ReviewerReportTask.where(phase: phase)).to be_empty
    end

    it "deletes paper roles not present in the specified user_id" do
      create(:paper_role, :reviewer, paper: paper, user: albert)
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.reviewers.where(paper: paper, user: albert)).to be_empty
    end

    context "when the 'Get Reviews' phase isn't present" do
      before do
        paper.phases.where(name: "Get Reviews").first.destroy!
      end

      context "and the phase is of the assign reviewer's phase" do
        it "associates the ReviewerReport task from that phase" do
          task.reviewer_ids = [neil.id.to_s]
          expect(StandardTasks::ReviewerReportTask.where(phase: task.phase)).to be_present
        end

        it "deletes the ReviewerReport from that phase" do
          task.reviewer_ids = [neil.id.to_s]
          expect(StandardTasks::ReviewerReportTask.where(phase: task.phase)).to be_present
          task.reviewer_ids = []
          expect(StandardTasks::ReviewerReportTask.where(phase: task.phase)).to_not be_present
        end
      end

      context "and the phase is changed for the ReviewerReport task" do
        it "removes the task from that phase" do
          task.reviewer_ids = [neil.id.to_s]
          reviewer_report_task = StandardTasks::ReviewerReportTask.where(phase: task.phase).first
          reviewer_report_task.update_attribute('phase_id', create(:phase, paper: paper).id)

          task.reviewer_ids = []
          expect(paper.tasks.where(type: StandardTasks::ReviewerReportTask)).to be_empty
        end
      end
    end
  end
end
