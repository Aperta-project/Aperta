require 'rails_helper'
# questions
shared_examples_for "person who can manage funders" do
  it "lets them do all the things" do
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot manage funders" do
  it "lets them do all the things" do
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

describe TahiStandardTasks::FundersPolicy do
  let(:policy) { TahiStandardTasks::FundersPolicy.new(current_user: user, funder: funder) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator, :with_tasks)
  end
  let(:task) { paper.phases.first.tasks.first }
  let(:funder) { TahiStandardTasks::Funder.new(task: task) }

  context "A super admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can manage funders"
  end

  context "Journal Admin" do
    let(:journal) { paper.journal }
    let(:user) do
      user = FactoryGirl.create(:user)
      assign_journal_role(journal, user, :admin)
      user
    end

    include_examples "person who can manage funders"
  end

  context "An author" do
    let(:user) { paper.creator }

    include_examples "person who can manage funders"
  end

  context "some schmuck" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot manage funders"
  end
end
