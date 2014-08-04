require 'spec_helper'

describe StandardTasks::FundersPolicy do
  let(:policy) { StandardTasks::FundersPolicy.new(current_user: user, funder: funder) }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:task) { paper.phases.first.tasks.first }
  let(:funder) { StandardTasks::Funder.new(task: task) }

  context "A super admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.create?).to eq(true) }
    it { expect(policy.update?).to eq(true) }
    it { expect(policy.destroy?).to eq(true) }
  end

  context "Journal Admin" do
    let(:journal) { paper.journal }
    let(:user) do
      user = FactoryGirl.create(:user)
      assign_journal_role(journal, user, :admin)
      user
    end

    it { expect(policy.create?).to eq(true) }
    it { expect(policy.update?).to eq(true) }
    it { expect(policy.destroy?).to eq(true) }
  end

  context "An author" do
    let(:user) { paper.user }

    it { expect(policy.create?).to eq(true) }
    it { expect(policy.update?).to eq(true) }
    it { expect(policy.destroy?).to eq(true) }
  end

  context "some schmuck" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.create?).to eq(false) }
    it { expect(policy.update?).to eq(false) }
    it { expect(policy.destroy?).to eq(false) }
  end
end
