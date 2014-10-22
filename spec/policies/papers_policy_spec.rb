require 'spec_helper'

describe PapersPolicy do
  let(:policy) { PapersPolicy.new(current_user: user, paper: paper) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(true) }
    it { expect(policy.submit?).to be(true) }
  end

  context "authors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, user: user) }

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(true) }
  end

  context "paper admins" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :admin, user: user, paper: paper)
    end

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(true) }
  end

  context "paper editors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :editor, user: user, paper: paper)
    end

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(true) }
  end

  context "paper reviewers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :reviewer, user: user, paper: paper)
    end

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(true) }
  end

  context "paper collaborators" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :collaborator, user: user, paper: paper)
    end

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.download?).to be(true) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(true) }
  end

  context "non-associated user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    it { expect(policy.edit?).to be(false) }
    it { expect(policy.show?).to be(false) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(false) }
    it { expect(policy.upload?).to be(false) }
    it { expect(policy.download?).to be(false) }
    it { expect(policy.heartbeat?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(false) }
  end

  context "locked paper" do
    let(:user) { FactoryGirl.build_stubbed(:user) }

    context "by current user" do
      let(:paper) { FactoryGirl.build_stubbed(:paper, locked_by_id: user.id) }
      it { expect(policy.heartbeat?).to be(true) }
    end

    context "by another user" do
      let(:paper) { FactoryGirl.build_stubbed(:paper, locked_by_id: 0) }
      it { expect(policy.heartbeat?).to be(false) }
    end
  end

  context "user with can_view_all_manuscript_managers on this paper's journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal) ],
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:journal) { FactoryGirl.create(:journal, papers: [paper]) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.toggle_editable?).to be(true) }
    it { expect(policy.submit?).to be(false) }
  end

  context "admin on different journal" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal) ],
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:journal) { FactoryGirl.create(:journal) }

    it { expect(policy.show?).to be(false) }
    it { expect(policy.upload?).to be(false) }
    it { expect(policy.toggle_editable?).to be(false) }
    it { expect(policy.submit?).to be(false) }
  end
end
