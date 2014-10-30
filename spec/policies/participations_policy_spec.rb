require 'spec_helper'

describe ParticipationsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:task) { create(:task, phase: phase) }
  let(:policy) { ParticipationsPolicy.new(current_user: user, task: task) }
  let(:user) { FactoryGirl.create(:user) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can edit a tasks's participants"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

    before do
      allow(task).to receive(:is_metadata?).and_return true
    end

    include_examples "person who can edit a tasks's participants"

    context "on a non metadata task" do
      before do
        allow(task).to receive(:is_metadata?).and_return false
      end
      include_examples "person who cannot edit a tasks's participants"
    end
  end

  context "task participant" do
    before do
      FactoryGirl.create(:participation, participant: user, task: task)
    end

    include_examples "person who can edit a tasks's participants"
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

      include_examples "person who can edit a tasks's participants"
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

    include_examples "person who can edit a tasks's participants"
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal), ],
      )
    end

    include_examples "person who can edit a tasks's participants"
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

    include_examples "person who can edit a tasks's participants"
  end
end
