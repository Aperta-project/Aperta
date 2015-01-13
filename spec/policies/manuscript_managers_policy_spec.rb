require 'rails_helper'

describe ManuscriptManagersPolicy do
  let(:policy) { ManuscriptManagersPolicy.new(current_user: user, paper: paper) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.show?).to be(true) }
  end

  context "non admin" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.show?).to be(false) }
  end

  context "user with manuscript manager role who is assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }
    let(:role) { FactoryGirl.create(:role, journal: journal, can_view_assigned_manuscript_managers: true) }
    before do
      UserRole.create!(user: user, role: role)
      task = paper.tasks.first
      task.participants << user
      task.save!
    end

    it { expect(policy.show?).to be(true) }
  end

  context "user with manuscript manager role who is not assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }
    let(:role) { FactoryGirl.create(:role, journal: journal, can_view_assigned_manuscript_managers: true) }
    before do
      UserRole.create!(user: user, role: role)
    end

    it { expect(policy.show?).to be(false) }
  end

  context "user with all manuscript managers role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:role) { FactoryGirl.create(:role, journal: journal, can_view_all_manuscript_managers: true) }
    before do
      UserRole.create!(user: user, role: role)
    end

    it { expect(policy.show?).to be(true) }
  end
end
