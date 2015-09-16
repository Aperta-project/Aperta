require 'rails_helper'

describe TahiStandardTasks::PaperEditorTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  let!(:author) { FactoryGirl.create :author, paper: paper }

  describe "#invitation_invited" do
    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        phase: paper.phases.first,
        title: "Invite Editor",
        role: "admin"
      })
    end
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations', invitee_role: 'editor'

    it "notifies the invited editor" do
      expect {
        task.invitation_invited(invitation)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end

    it "adds author information to Invitation#information=" do
      task.invitation_invited(invitation)
      expect(invitation.information).to eq("Here are the authors on the paper:\n\n1. #{author.last_name}, #{author.first_name} from #{author.specific.affiliation}")
    end
  end

  describe "#invitation_accepted" do

    let!(:sample_editor_task) do
      Task.create!({
        phase: paper.phases.first,
        title: "Sample Editor Task",
        role: "editor"
      })
    end

    let!(:sample_reviewer_report_task) do
      TahiStandardTasks::ReviewerReportTask.create!({
        phase: paper.phases.first,
        title: "Sample Report Task",
        role: "reviewer"
      })
    end

    let!(:sample_reviewer_recommendation_task) do
      TahiStandardTasks::ReviewerRecommendationsTask.create!({
        phase: paper.phases.first,
        title: "Sample Rec Task",
        role: "author"
      })
    end

    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        phase: paper.phases.first,
        title: "Invite Editor",
        role: "admin"
      })
    end

    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it "replaces the old editor" do
      invitation.accept!
      expect(paper.reload.editor).to eq(invitation.invitee)
    end

    it "follows tasks with editor role to the new editor" do
      invitation.accept!
      expect(sample_editor_task.participations.map(&:user)).to include(invitation.invitee)
    end

    it "follows all tasks that are reviewer reports" do
      invitation.accept!
      expect(sample_reviewer_report_task.participations.map(&:user)).to include(invitation.invitee)
    end

    it "follows reviewer recommendations task" do
      invitation.accept!
      expect(sample_reviewer_recommendation_task.participations.map(&:user)).to include(invitation.invitee)
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
