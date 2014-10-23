require 'spec_helper'

def run_shared_example(example)
  include_examples example
  it_behaves_like example
end

describe TasksPolicy do

  let(:policy) { TasksPolicy.new(current_user: user, task: task) }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:task) { paper.tasks.first }
  let(:journal) { FactoryGirl.create(:journal, papers: [paper]) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    run_shared_example "administrator for task"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }
    let(:task) { paper.tasks.metadata.first }
    let(:user) { FactoryGirl.create(:user) }

    run_shared_example "person who can edit but not create a task"

    context "on a non metadata task" do
      let(:task) { paper.tasks.where.not(type: Task.metadata_types).first }

      run_shared_example "person who cannot see a task"
    end
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal), ],
      )
    end

    run_shared_example "administrator for task"
  end

  context "user no role" do
    let(:user) { FactoryGirl.create(:user) }

    run_shared_example "person who cannot see a task"
  end

  context "user with role on different journal" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal) ],
      )
      end

    run_shared_example "person who cannot see a task"
  end

  context "user with can_view_assigned_manuscript_managers on this journal and is assigned to the paper." do
    let(:journal_role) { FactoryGirl.create(:role, journal: journal, can_view_assigned_manuscript_managers: true) }
    let(:user) do
      user = FactoryGirl.create(:user)
      user.roles << journal_role
      user
    end

    before do
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
    end

    run_shared_example "administrator for task"
  end

  context "task participant" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:participation, participant: user, task: task)
    end

    run_shared_example "person who can edit but not create a task"
  end

  context "allowed reviewer" do
    %i(reviewer editor).each do |role|
      let(:user) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:paper_role, role, user: user, paper: paper)
        user
      end

      before do
        task.update_attribute(:role, 'reviewer')
      end

      run_shared_example "person who can edit but not create a task"
    end
  end

  context "allowed manuscript information task" do
    let(:user) do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
      user
    end

    before do
      task.update_attribute(:role, 'author')
    end

    run_shared_example "person who can edit but not create a task"
  end
end
