require 'rails_helper'

describe TasksPolicy do

  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { create(:task, paper: paper) }
  let(:policy) { TasksPolicy.new(current_user: user, task: task) }
  let(:user) { FactoryGirl.create(:user) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "administrator for task"
  end

  context "paper collaborator" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }
    let(:task) { create(:submission_task, paper: paper) }

    include_examples "person who can edit but not create a task"

    context "on a non submission task" do
      let(:task) { create(:task, paper: paper) }

      include_examples "person who cannot see a task"
    end
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let(:user) do
      FactoryGirl.create(
        :user,
        old_roles: [ FactoryGirl.create(:old_role, :admin, journal: journal), ],
      )
    end

    include_examples "administrator for task"
  end

  context "user no old_role" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    include_examples "person who cannot see a task"
  end

  context "user with old_role on different journal" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let(:other_journal) do
      FactoryGirl.create(:journal, :with_roles_and_permissions)
    end
    let(:user) do
      FactoryGirl.create(
        :user,
        old_roles: [ FactoryGirl.create(:old_role, :admin, journal: other_journal) ],
      )
      end

    include_examples "person who cannot see a task"
  end

  context "user with can_view_assigned_manuscript_managers on this journal and is assigned to the paper." do
    let(:journal_role) { FactoryGirl.create(:old_role, journal: journal, can_view_assigned_manuscript_managers: true) }
    let(:user) do
      user = FactoryGirl.create(:user)
      user.old_roles << journal_role
      user
    end

    before do
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
    end

    include_examples "administrator for task"
  end

  context "task participant" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

    before do
      task.add_participant user
    end

    include_examples "person who can edit but not create a task"
  end
end
