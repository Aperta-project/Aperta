require 'rails_helper'

describe TahiStandardTasks::PaperEditorTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe "#invitation_invited" do
    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        phase: paper.phases.first,
        title: "Assign Editor",
        role: "admin"
      })
    end
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "notifies the invited editor" do
      expect {
        task.invitation_invited(invitation)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end
  end

  describe "#invitation_accepted" do

    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        phase: paper.phases.first,
        title: "Assign Editor",
        role: "admin"
      })
    end
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "replaces the old editor" do
      invitation.accept!
      expect(paper.reload.editor).to eq(invitation.invitee)
    end

    context "when there's an existing editor" do

      before { FactoryGirl.create(:paper_role, :editor, paper: paper, user: FactoryGirl.create(:user)) }

      it "replaces the old editor" do
        invitation.accept!
        expect(paper.reload.editor).to eq(invitation.invitee)
      end

    end
  end
end
