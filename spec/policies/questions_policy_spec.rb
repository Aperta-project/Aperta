require 'spec_helper'

describe QuestionsPolicy do
  let(:policy) { QuestionsPolicy.new(current_user: user, question: question) }
  let(:question) { FactoryGirl.create(:question, task: task) }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:task) { paper.phases.first.tasks.first }

  context "A super admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can manage questions"
  end

  context "An author" do
    let(:user) { paper.user }

    include_examples "person who can manage questions"
  end

  context "paper reviewer for a reviewer task" do
    let!(:paper_role) { create(:paper_role, :reviewer, user: user, paper: paper) }
    let(:task) { paper.tasks.first }
    let(:user) { FactoryGirl.create(:user) }

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
