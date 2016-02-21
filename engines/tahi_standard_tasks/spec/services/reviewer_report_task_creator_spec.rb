require 'rails_helper'

describe ReviewerReportTaskCreator do
  let!(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let!(:task) { FactoryGirl.create(:task, paper: paper) }
  let!(:assignee) { FactoryGirl.create(:user) }

  subject do
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: assignee.id
    )
  end

  context "assigning reviewer old_role" do
    context "with no existing reviewer" do
      it "assigns reviewer old_role to the assignee" do
        subject.process
        expect(
          PaperRole.where(
            paper: paper,
            user: assignee,
            old_role: PaperRole::REVIEWER
          )
        ).to exist
      end

      it "creates a ReviewerReportTask" do
        expect {
          subject.process
        }.to change { TahiStandardTasks::ReviewerReportTask.count }.by(1)
      end

      it 'assigns the user as a Participant on the Paper' do
        expect { subject.process }.to change { Assignment.count }

        assignment = Assignment.where(
          user: assignee,
          role: paper.journal.reviewer_role,
          assigned_to: paper
        ).first!
        expect(assignment).to be
      end

      it 'assigns the user as a Participant on the ReviewerReportTask' do
        expect { subject.process }.to change { Assignment.count }

        task = TahiStandardTasks::ReviewerReportTask.last
        assignment = Assignment.where(
          user: assignee,
          role: paper.journal.participant_role,
          assigned_to: task
        ).first!
        expect(assignment).to be
      end
    end

    context "with an existing reviewer" do
      before do
        existing_reviewer = FactoryGirl.create(:user)
        make_user_paper_reviewer(existing_reviewer, paper)
      end

      it "assigns reviewer old_role to the assignee" do
        subject.process
        expect(
          PaperRole.where(
            paper: paper,
            user: assignee,
            old_role: PaperRole::REVIEWER
          )
        ).to exist
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
        originating_task: task, assignee_id: assignee.id
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
end
