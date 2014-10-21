require 'spec_helper'

describe ManuscriptManagerTemplatesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:manuscript_manager_template) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let(:policy) { ManuscriptManagerTemplatesPolicy.new(current_user: user, manuscript_manager_template: manuscript_manager_template) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.show?).to be(false) }
    it { expect(policy.update?).to be(false) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.destroy?).to be(false) }
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end
end
