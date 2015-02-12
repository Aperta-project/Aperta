require 'rails_helper'

describe StandardTasks::PaperEditorTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe "#invitation_accepted" do

    let!(:task) { StandardTasks::PaperEditorTask.create!(phase: paper.phases.first, title: "Assign Editor", role: 'admin') }
    let(:invitation) { FactoryGirl.create(:invitation, task: task) }

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
