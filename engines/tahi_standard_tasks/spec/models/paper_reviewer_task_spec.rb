require 'rails_helper'

describe TahiStandardTasks::PaperReviewerTask do
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

  let(:albert) { create :user, :site_admin }
  let(:neil) { create :user }
  let!(:task) do
    TahiStandardTasks::PaperReviewerTask.create!({
      phase: paper.phases.first,
      title: "Invite Reviewers",
      role: "admin"
    })
  end

  describe "#invitation_invited" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "notifies the invited reviewer" do
      expect {task.invitation_invited invitation}.to change {
        Sidekiq::Extensions::DelayedMailer.jobs.length
      }.by 1
    end
  end

  describe "#invitation_accepted" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "adds the reviewer to the list of reviewers" do
      expect(paper.reviewers.count).to eq 0
      invitation.accept!
      expect(paper.reviewers.count).to eq 1
      expect(paper.reload.reviewers).to include invitation.invitee
    end
  end

  describe "#invitation_rescinded" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "sends an email to the invitee about the rescission" do
      expect do
        task.invitation_rescinded paper_id: invitation.paper.id,
                                  invitee_id: invitation.invitee.id
      end.to change { Sidekiq::Extensions::DelayedMailer.jobs.length }.by 1
    end
  end
end
