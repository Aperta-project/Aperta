require 'spec_helper'

describe AdministrateJournalPolicy do
  let(:policy) { AdministrateJournalPolicy.new(current_user: user) }
  let(:journal) { FactoryGirl.create(:journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.index?).to be(true) }
  end

  context "non admin who does not administer any journal" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.index?).to be(false) }
  end

  context "user who administers any journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it { expect(policy.index?).to be(true) }
  end
end

