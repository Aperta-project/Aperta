require 'spec_helper'

describe RolesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { RolesPolicy.new(current_user: user, journal: journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.update?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.update?).to be(false) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.destroy?).to be(false) }
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it { expect(policy.update?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end
end
