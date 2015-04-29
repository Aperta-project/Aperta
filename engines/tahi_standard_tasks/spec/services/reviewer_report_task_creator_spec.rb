require 'rails_helper'

describe ReviewerReportTaskCreator do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_reviewer_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }
  let(:assignee) { FactoryGirl.create(:user) }

  subject do
    ReviewerReportTaskCreator.new(originating_task: paper_reviewer_task, assignee_id: assignee.id)
  end

  it "assigns the specified role to the assignee" do
    subject.process
    expect(paper.role_for(user: assignee, role: PaperRole::REVIEWER)).to exist
  end

  it "creates a ReviewerReportTask" do
    expect {
      subject.process
    }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(1)
  end

  context "with existing ReviewerReportTask for User" do
    before do
      subject.process
    end

    it "finds existing ReviewerReportTask" do
      expect {
        subject.process
      }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(0)
    end
  end

  it "adds the assignee as a participant to the ReviewerReportTask" do
    subject.process
    expect(paper.tasks_for_type("TahiStandardTasks::ReviewerReportTask").first.participants).to match_array([assignee])
  end
end
