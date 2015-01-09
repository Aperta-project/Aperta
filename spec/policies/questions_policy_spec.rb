require 'rails_helper'

describe QuestionsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:task) { create(:task, phase: phase) }
  let(:user) { FactoryGirl.create(:user) }
  let(:question) { FactoryGirl.create(:question, task: task) }
  let(:policy) { QuestionsPolicy.new(current_user: user, question: question) }

  context "A super admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can manage questions"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

    before do
      allow(task).to receive(:is_metadata?).and_return true
    end
    include_examples "person who can manage questions"

    context "on a non metadata task" do
      before do
        allow(task).to receive(:is_metadata?).and_return false
      end
      include_examples "person who cannot manage questions"
    end
  end

  context "paper reviewer for a reviewer task" do
    let!(:paper_role) { create(:paper_role, :reviewer, user: user, paper: paper) }

    before do
      task.role = 'reviewer'
    end

    include_examples "person who can manage questions"
  end

  context "some schmuck" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot manage questions"
  end
end
