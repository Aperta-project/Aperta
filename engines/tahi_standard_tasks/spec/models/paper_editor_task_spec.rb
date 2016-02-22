require 'rails_helper'

describe TahiStandardTasks::PaperEditorTask do
  let(:paper) do
    FactoryGirl.create :paper, :with_integration_journal, :with_tasks
  end

  let!(:author) { FactoryGirl.create :author, paper: paper }

  describe "#invitation_invited" do
    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        paper: paper,
        phase: paper.phases.first,
        title: "Invite Editor",
        old_role: "admin"
      })
    end
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
                    invitee_role: Role::ACADEMIC_EDITOR_ROLE

    it "notifies the invited editor" do
      expect {
        task.invitation_invited(invitation)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end

    it "adds author information to Invitation#information=" do
      task.invitation_invited(invitation)
      expect(invitation.information).to eq("Here are the authors on the paper:\n\n1. #{author.last_name}, #{author.first_name} from #{author.affiliation}")
    end
  end

  describe "#invitation_accepted" do

    let!(:sample_editor_task) do
      Task.create!({
        paper: paper,
        phase: paper.phases.first,
        title: "Sample Editor Task",
        old_role: "editor"
      })
    end

    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        paper: paper,
        phase: paper.phases.first,
        title: "Invite Editor",
        old_role: "admin"
      })
    end

    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "replaces the old editor" do
      invitation.accept!
      expect(paper.reload.academic_editor).to eq(invitation.invitee)
    end

    context "when there's an existing editor" do
      let(:paper) do
        FactoryGirl.create(
          :paper,
          :with_integration_journal,
          :with_academic_editor_user,
          :with_tasks
        )
      end

      it "replaces the old editor" do
        invitation.accept!
        expect(paper.reload.academic_editor).to eq(invitation.invitee)
      end
    end
  end
end
