require 'rails_helper'

describe ReviewerReportTaskCreator do
  let!(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_task_participant_role,
      :with_reviewer_role,
      :with_reviewer_report_owner_role
    )
  end
  let!(:paper) { FactoryGirl.create(:paper, :submitted, journal: journal) }
  let!(:originating_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }
  let!(:assignee) { FactoryGirl.create(:user) }

  subject do
    ReviewerReportTaskCreator.new(
      originating_task: originating_task,
      assignee_id: assignee.id
    )
  end

  context "when the paper is configured to use the research reviewer report" do
    let!(:card) { FactoryGirl.create(:card, journal: journal, name: 'ReviewerReport') }
    before do
      paper.update_column :uses_research_article_reviewer_report, true
    end

    it "sets the task to be a ReviewerReportTask" do
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::ReviewerReportTask)
    end


    it "sets the card to be one named 'ReviewerReport'" do
      task = subject.process
      expect(task.card.name).to eq('ReviewerReport')
    end

    it_behaves_like 'creating a reviewer report task', reviewer_report_type: TahiStandardTasks::ReviewerReportTask
  end

  context "when the paper is not configured to use the research reviewer report" do
    before do
      paper.update_column :uses_research_article_reviewer_report, false
    end

    it "sets the task to be a FrontMatterReviewerReportTask" do
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::FrontMatterReviewerReportTask)
    end

    it "sets the card to be one named 'FrontMatterReviewerReport'" do
      task = subject.process
      expect(task.card.name).to eq('FrontMatterReviewerReport')
    end

    it_behaves_like 'creating a reviewer report task', reviewer_report_type: TahiStandardTasks::FrontMatterReviewerReportTask
  end
end
