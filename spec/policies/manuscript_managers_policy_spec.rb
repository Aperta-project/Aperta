require 'rails_helper'

describe ManuscriptManagersPolicy do
  let(:policy) { ManuscriptManagersPolicy.new(current_user: user, paper: paper) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end

  context "non admin" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.show?).to be(false) }
    it { expect(policy.can_manage_manuscript?).to be(false) }
  end

  context "user with manuscript manager role who is assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:role) { FactoryGirl.create(:role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, role)
      task = paper.tasks.first
      task.participants << user
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end

  context "user with manuscript manager role who is assigned to the paper" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:role) { FactoryGirl.create(:role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      role.update_attribute :can_view_assigned_manuscript_managers, true
      assign_journal_role(paper.journal, user, role)
      assign_paper_role(paper, user, PaperRole::EDITOR)
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end

  context "user with manuscript manager role who is not assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:role) { FactoryGirl.create(:role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, role)
    end

    it { expect(policy.show?).to be(false) }
    it { expect(policy.can_manage_manuscript?).to be(false) }
  end

  context "user with all manuscript managers role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:role) { FactoryGirl.create(:role, journal: paper.journal, can_view_all_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, role.kind)
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end
end
