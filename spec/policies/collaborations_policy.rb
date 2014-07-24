require 'spec_helper'

describe CollaborationsPolicy do
  let(:policy) { CollaborationsPolicy.new(current_user: user, paper: paper) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "authors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, user: user) }

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "paper admins" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :admin, user: user, paper: paper)
    end

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "paper editors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :editor, user: user, paper: paper)
    end

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "paper reviewers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :reviewer, user: user, paper: paper)
    end

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "paper collaborators" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :collaborator, user: user, paper: paper)
    end

    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "non-associated user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.create?).to be(false) }
    it { expect(policy.destroy?).to be(false) }
  end
end
