require 'rails_helper'

describe PaperRolesPolicy do
  let(:policy) { PaperRolesPolicy.new(current_user: user, paper: paper) }
  let(:user){ raise NotImplementError, "Must provide :user"}

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.index?).to be(true) }
  end

  context "non admin" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.index?).to be(false) }
  end

  context "user with manuscript manager old_role who is assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, old_role)
      task = paper.tasks.first
      task.add_participant(user)
    end

    it { expect(policy.index?).to be(true) }
  end

  context "user with manuscript manager old_role who is assigned to the paper" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      old_role.update_attribute :can_view_assigned_manuscript_managers, true
      assign_journal_role(paper.journal, user, old_role)
      assign_paper_role(paper, user, PaperRole::EDITOR)
    end

    it { expect(policy.index?).to be(true) }
  end

  context "user with manuscript manager old_role who is not assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, old_role)
    end

    it { expect(policy.index?).to be(false) }
  end

  context "user with all manuscript managers old_role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_all_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, old_role.kind)
    end

    it { expect(policy.index?).to be(true) }
  end
end
