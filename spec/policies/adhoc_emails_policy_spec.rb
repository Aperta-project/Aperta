require 'spec_helper'

describe TasksPolicy do
  let(:policy) { AdhocEmailsPolicy.new(current_user: user, task: task) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.send_message?).to be(true) }
  end

  context "paper collaborator" do
    let!(:paper_role) { FactoryGirl.create(:paper_role, :collaborator, user: user, paper: paper) }
    let(:user) { FactoryGirl.create(:user) }
    before {
      task.participants << user
    }

    it { expect(policy.send_message?).to be(true) }
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: paper.journal) ]
      )
    end

    it { expect(policy.send_message?).to be(true) }
  end

  context "user no role" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.send_message?).to be(false) }
  end

  context "user with role on different journal" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal) ])
    end

    it { expect(policy.send_message?).to be(false) }
  end

  context "user with can_view_assigned_manuscript_managers on this journal and is assigned to the paper." do
    let(:journal_role) { FactoryGirl.create(:role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }
    let(:user) do
      user = FactoryGirl.create(:user)
      user.roles << journal_role
      user
    end

    before do
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
    end

    it { expect(policy.send_message?).to be(true) }
  end

  context "task participant" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:participation, participant: user, task: task)
    end

    it { expect(policy.send_message?).to be(true) }
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

      it { expect(policy.send_message?).to be(true) }
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

    it { expect(policy.send_message?).to be(true) }
  end
end
