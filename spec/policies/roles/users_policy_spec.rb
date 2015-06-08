require 'rails_helper'

describe Roles::UsersPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { Roles::UsersPolicy.new(current_user: user, journal: journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can read roles' users"
  end

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can read roles' users"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot read roles' users"
    include_examples "person who cannot administer journal roles"
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can read roles' users"
  end
end
