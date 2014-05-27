require 'spec_helper'

describe JournalPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { JournalPolicy.new(current_user: user, journal: journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(false) }
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
  end
end
