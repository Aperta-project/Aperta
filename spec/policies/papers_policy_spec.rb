require 'spec_helper'

describe PapersPolicy do
  let(:policy) { PapersPolicy.new(current_user: user, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "administrator for paper"
  end

  context "authors" do
    let(:paper) { FactoryGirl.create(:paper, creator: user) }

    include_examples "author for paper"
  end

  context "paper admins" do
    before do
      create(:paper_role, :admin, user: user, paper: paper)
    end

    include_examples "author for paper"
  end

  context "paper editors" do
    before do
      create(:paper_role, :editor, user: user, paper: paper)
    end

    include_examples "author for paper"
  end

  context "paper reviewers" do
    before do
      create(:paper_role, :reviewer, user: user, paper: paper)
    end

    include_examples "author for paper"
  end

  context "paper collaborators" do
    before do
      create(:paper_role, :collaborator, user: user, paper: paper)
    end

    include_examples "author for paper"
  end

  context "non-associated user" do
    include_examples "person who cannot see a paper"
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
    let(:journal) { FactoryGirl.create(:journal, papers: [paper]) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.upload?).to be(true) }
    it { expect(policy.manage?).to be(true) }
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

    include_examples "person who cannot see a paper"
  end
end
