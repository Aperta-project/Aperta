require 'rails_helper'

describe TahiStandardTasks::PaperReviewerTask do
  subject(:task) do
    FactoryGirl.create(:paper_reviewer_task, paper: paper)
  end

  let(:paper) do
    FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
  end
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe "#invitation_invited" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
      invitee_role: Role::REVIEWER_ROLE

    it "notifies the invited reviewer" do
      expect {task.invitation_invited invitation}.to change {
        Sidekiq::Extensions::DelayedMailer.jobs.length
      }.by(1)
    end
  end

  describe "#invitation_accepted" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }
    before do
      allow(ReviewerReportTaskCreator).to \
        receive(:new).
        and_return double(process: nil)
    end

    context "with an academic editor" do
      let(:paper) do
        FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
      end
      let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }

      before do
        academic_editor = paper.assignments.find_by \
          role: journal.academic_editor_role
        expect(academic_editor).to be
      end

      it "queues the email" do
        expect {task.invitation_accepted invitation}.to change {
          Sidekiq::Extensions::DelayedMailer.jobs.length
        }.by(1)
      end
    end

    context "without a paper editor" do
      before do
        paper.assignments.where(role: paper.journal.academic_editor_role)
          .destroy_all
      end

      it "queues the email" do
        expect {task.invitation_accepted invitation}.to change {
          Sidekiq::Extensions::DelayedMailer.jobs.length
        }.by(1)
      end
    end
  end

  describe "#invitation_declined" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    context "with a paper editor" do
      it "queues the email" do
        expect { task.invitation_declined invitation }.to change {
          Sidekiq::Extensions::DelayedMailer.jobs.length
        }.by(1)
      end
    end

    context "without a paper editor" do
      before do
        paper.assignments.where(role: paper.journal.academic_editor_role)
          .destroy_all
      end

      it "queues the email" do
        expect { task.invitation_declined invitation }.to change {
          Sidekiq::Extensions::DelayedMailer.jobs.length
        }.by(1)
      end
    end
  end
end
