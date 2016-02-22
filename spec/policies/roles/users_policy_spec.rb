require 'rails_helper'

describe OldRoles::UsersPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { OldRoles::UsersPolicy.new(current_user: user, journal: journal) }
  let(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    it "can modify everything" do
      expect(policy.index?).to be(true)
    end
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    it "can modify everything" do
      expect(policy.index?).to be(false)
    end
  end

  context "user who administers the journal" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it "can modify everything" do
      expect(policy.index?).to be(true)
    end
  end
end
