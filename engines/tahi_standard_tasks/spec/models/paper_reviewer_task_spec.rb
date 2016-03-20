require 'rails_helper'

describe TahiStandardTasks::PaperReviewerTask do
  let!(:journal) do
    journal = create :journal, :with_roles_and_permissions
    journal.manuscript_manager_templates.destroy_all
    mmt = create :manuscript_manager_template, journal: journal
    mmt.phase_templates.create! name: "Collect Info"
    mmt.phase_templates.create! name: "Get Reviews"
    journal
  end
  let(:paper) do
    FactoryGirl.create(:paper, :with_tasks, :with_academic_editor_user,
                       journal: journal)
  end
  let(:phase) { paper.phases.first }

  let(:albert) { create :user, :site_admin }
  let(:neil) { create :user }
  let!(:task) do
    TahiStandardTasks::PaperReviewerTask.create!({
      paper: paper,
      phase: paper.phases.first,
      title: "Invite Reviewers",
      old_role: "editor"
    })
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
      allow(ReviewerReportTaskCreator).to receive(:new).and_return(double(process: nil))
    end

    context "with a paper editor" do
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

  describe "#invitation_rejected" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    context "with a paper editor" do
      it "queues the email" do
        expect {task.invitation_rejected invitation}.to change {
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
        expect {task.invitation_rejected invitation}.to change {
          Sidekiq::Extensions::DelayedMailer.jobs.length
        }.by(1)
      end
    end
  end

  describe "#invitation_rescinded" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "sends an email to the invitee about the rescission" do
      expect {
        task.invitation_rescinded(invitation)
      }.to change { Sidekiq::Extensions::DelayedMailer.jobs.length }.by 1
    end
  end
end
