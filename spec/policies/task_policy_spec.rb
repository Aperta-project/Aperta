require 'spec_helper'

describe TaskPolicy do
  describe "#tasks" do
    let(:user) { FactoryGirl.create(:user) }
    let(:editor) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, user: user) }
    let(:phase1) { FactoryGirl.create(:phase, paper: paper) }
    let!(:user_assigned_task) {
      Task.create!(title: 'User task', role: 'whatever', phase: phase1, assignee: user)
    }
    let!(:editor_assigned_task) {
      Task.create!(title: 'PaperAdminTask', role: 'whatever', phase: phase1, assignee: editor)
    }
    let!(:reviewer_task) {
      Task.create! title: 'Reviewer Report', role: 'reviewer', phase: phase1
    }

    before do
      paper.paper_roles.create! user: editor, editor: true
    end

    context "when the user is not an editor of the paper" do
      subject { TaskPolicy.new(paper, user).tasks }

      it "returns the tasks assigned to the current user" do
        expect(subject).to eq([user_assigned_task])
      end
    end

    context "when the user is an editor on the paper" do
      subject { TaskPolicy.new(paper, editor).tasks }

      it "returns the tasks assigned to the user" do
        expect(subject).to include(editor_assigned_task)
      end

      it "returns the tasks marked by 'reviewer' role" do
        expect(subject).to include(reviewer_task)
      end
    end
  end
end
