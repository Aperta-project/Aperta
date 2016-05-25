require 'rails_helper'

describe ReviewerReportTaskCreator do
  let!(:journal) do
    FactoryGirl.create(
      :journal,
      :with_task_participant_role,
      :with_reviewer_role,
      :with_reviewer_report_owner_role
    )
  end
  let!(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:originating_task) { FactoryGirl.create(:task, paper: paper) }
  let!(:assignee) { FactoryGirl.create(:user) }

  subject do
    ReviewerReportTaskCreator.new(
      originating_task: originating_task,
      assignee_id: assignee.id
    )
  end

  context "assigning reviewer old_role" do
    context "with no existing reviewer" do
      it "creates a ReviewerReportTask" do
        expect {
          subject.process
        }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(1)
      end

      it 'creates new assignments' do
        expect { subject.process }.to change { Assignment.count }.by(3)
      end

      it 'assigns the user as a Participant on the Paper' do
        subject.process
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_role,
            assigned_to: paper
          )
        ).to be
      end

      it 'assigns the user as a Participant on the ReviewerReportTask' do
        subject.process
        task = TahiStandardTasks::ReviewerReportTask.last
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.task_participant_role,
            assigned_to: task
          )
        ).to be
      end

      it 'assigns the user as a Reviewer Report Owner on the task' do
        subject.process
        task = TahiStandardTasks::ReviewerReportTask.last
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_report_owner_role,
            assigned_to: task
          )
        ).to be
      end
    end

    context "with an existing reviewer" do
      before do
        FactoryGirl.create(:user).tap do |reviewer|
          reviewer.assignments.create!(
            assigned_to: originating_task,
            role: paper.journal.reviewer_role
          )
        end
      end

      it "creates a ReviewerReportTask" do
        expect {
          subject.process
        }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(1)
      end
    end
  end

  context "with existing ReviewerReportTask for User" do
    before do
      subject.process
      TahiStandardTasks::ReviewerReportTask.first.update(completed: true)
    end

    it "finds existing ReviewerReportTask" do
      expect {
        subject.process
      }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(0)
    end

    it "uncompletes and unsubmits ReviewerReportTask" do
      ReviewerReportTaskCreator.new(
        originating_task: originating_task,
        assignee_id: assignee.id
      ).process
      expect(TahiStandardTasks::ReviewerReportTask.count).to eq 1
      expect(TahiStandardTasks::ReviewerReportTask.first.completed).to eq false
      expect(TahiStandardTasks::ReviewerReportTask.first.submitted?).to eq false
    end
  end

  it "adds the assignee as a participant to the ReviewerReportTask" do
    subject.process
    expect(paper.tasks_for_type("TahiStandardTasks::ReviewerReportTask").first.participants).to match_array([assignee])
  end

  context 'when assigning a new reviewer' do
    it 'sends the welcome email' do
      expect(TahiStandardTasks::ReviewerMailer).to \
        receive_message_chain('delay.welcome_reviewer')
      subject.process
    end
  end

  context "when the paper is configured to use the research reviewer report" do
    it "sets the task to be a ReviewerReportTask" do
      paper.update_column :uses_research_article_reviewer_report, true
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::ReviewerReportTask)
    end
  end

  context "when the paper is not configured to use the research reviewer report" do
    it "sets the task to be a FrontMatterReviewerReportTask" do
      paper.update_column :uses_research_article_reviewer_report, false
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::FrontMatterReviewerReportTask)
    end
  end
end
