require 'rails_helper'

describe OldRolesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:old_role) { nil }
  let(:policy) { OldRolesPolicy.new(current_user: user, journal: journal, old_role: old_role) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer journal old_roles"
  end

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer journal old_roles"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot administer journal old_roles"
  end

  context "user who administers the journal" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let(:user) { FactoryGirl.create(:user) }
    let(:old_role) { assign_journal_role(journal, user, :admin) }

    include_examples "person who can administer journal old_roles"
  end

  context "user who has a old_role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:old_role) { assign_journal_role(journal, user, OldRole.first) }

    specify { expect(policy.show?).to be(true) }
  end
end
