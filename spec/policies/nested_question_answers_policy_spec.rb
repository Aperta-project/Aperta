require 'rails_helper'

describe NestedQuestionAnswersPolicy do
  subject(:policy) { NestedQuestionAnswersPolicy.new(current_user: user, nested_question_answer: nested_question_answer) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, phase: phase) }
  let(:nested_question_answer) { fail NotImplementedError("Must provide :nested_question_answer in context") }

  context "and the resource is owned by a task" do
    let(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, owner: task) }

    context "A super admin" do
      let(:user) { FactoryGirl.create(:user, :site_admin) }

      include_examples "person who can manage questions"
    end

    context "paper collaborator" do
      let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

      before do
        allow(task).to receive(:submission_task?).and_return true
      end
      include_examples "person who can manage questions"

      context "on a non metadata task" do
        before do
          allow(task).to receive(:submission_task?).and_return false
        end
        include_examples "person who cannot manage questions"
      end
    end

    context "paper reviewer for a reviewer task" do
      let!(:paper_role) { create(:paper_role, :reviewer, user: user, paper: paper) }

      before do
        task.old_role = 'reviewer'
      end

      include_examples "person who can manage questions"
    end

    context "some schmuck" do
      let(:user) { FactoryGirl.create(:user) }

      include_examples "person who cannot manage questions"
    end
  end

  context "and the resource isn't owned by a task, but it's owner is assigned to a task" do
    let(:comment) { FactoryGirl.create(:comment, task: task) }
    let(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, owner: comment) }

    context "A super admin" do
      let(:user) { FactoryGirl.create(:user, :site_admin) }

      include_examples "person who can manage questions"
    end

    context "paper collaborator" do
      let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

      before do
        allow(task).to receive(:submission_task?).and_return true
      end
      include_examples "person who can manage questions"

      context "on a non metadata task" do
        before do
          allow(task).to receive(:submission_task?).and_return false
        end
        include_examples "person who cannot manage questions"
      end
    end

    context "paper reviewer for a reviewer task" do
      let!(:paper_role) { create(:paper_role, :reviewer, user: user, paper: paper) }

      before do
        task.old_role = 'reviewer'
      end

      include_examples "person who can manage questions"
    end

    context "some schmuck" do
      let(:user) { FactoryGirl.create(:user) }

      include_examples "person who cannot manage questions"
    end
  end
end
