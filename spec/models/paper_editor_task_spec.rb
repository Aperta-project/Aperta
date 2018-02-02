require 'rails_helper'

describe PaperEditorTask do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper_with_phases, journal: journal) }
  let!(:author) { FactoryGirl.create(:author, paper: paper) }
  let(:task) do
    FactoryGirl.create(
      :paper_editor_task,
      paper: paper,
      phase: paper.phases.first
    )
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#invitation_invited" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
      invitee_role: Role::ACADEMIC_EDITOR_ROLE

    it "notifies the invited editor" do
      expect do
        task.invitation_invited(invitation)
      end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end
  end

  describe "#invitation_accepted" do
    before do
      Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE, journal: journal)
    end

    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it 'adds the invitee as an Academic Editor on the paper' do
      invitation.accept!
      expect(paper.academic_editors).to include(invitation.invitee)
    end

    it 'does not queue up any emails' do
      expect do
        invitation.accept!
      end.to_not change { Sidekiq::Extensions::DelayedMailer.jobs.count }
    end
  end

  describe "PaperEditorTask.task_added_to_paper" do
    it "creates a queue for the task" do
      task.task_added_to_paper(task)
      expect(task.invitation_queue).to be_present
    end
  end
end
