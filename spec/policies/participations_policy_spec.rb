require 'rails_helper'

describe ParticipationsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:participation) { FactoryGirl.create(:participation, task: task) }
  let(:policy) { ParticipationsPolicy.new(current_user: user, resource: participation) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can edit a tasks's participants"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

    before do
      allow(task).to receive(:submission_task?).and_return true
    end

    include_examples "person who can edit a tasks's participants"

    context "on a non metadata task" do
      before do
        allow(task).to receive(:submission_task?).and_return false
      end
      include_examples "person who cannot edit a tasks's participants"
    end
  end

  context "task participant" do
    before do
      FactoryGirl.create(:participation, user: user, task: task)
    end

    include_examples "person who can edit a tasks's participants"
  end

  context "allowed reviewer" do
    %i(reviewer editor).each do |old_role|
      let(:user) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:paper_role, old_role, user: user, paper: paper)
        user
      end

      before do
        task.update_attribute(:old_role, 'reviewer')
      end

      include_examples "person who can edit a tasks's participants"
    end
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        old_roles: [ FactoryGirl.create(:old_role, :admin, journal: journal), ],
      )
    end

    include_examples "person who can edit a tasks's participants"
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

    include_examples "person who can edit a tasks's participants"
  end
end
