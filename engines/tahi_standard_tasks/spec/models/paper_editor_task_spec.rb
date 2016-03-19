require 'rails_helper'

describe TahiStandardTasks::PaperEditorTask do
  let(:journal) { FactoryGirl.create(:journal )}
  let(:paper) { FactoryGirl.create(:paper_with_phases, journal: journal) }
  let!(:author) { FactoryGirl.create(:author, paper: paper) }

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
  end

  describe "#invitation_accepted" do
    before do
      Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE, journal: journal)
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

    it 'adds the invitee as an Academic Editor on the paper' do
      invitation.accept!
      expect(paper.academic_editors).to include(invitation.invitee)
    end
  end
end
