require 'rails_helper'

describe Admin::JournalsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { Admin::JournalsPolicy.new(current_user: user, journal: journal) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer all journals (site admin)"
  end

  context "non site admin" do
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let(:user) { FactoryGirl.create(:user) }

    context "who doesn't administer any journals" do
      include_examples "person who cannot administer any journal"
    end

    context "who administers the journal" do
      before do
        assign_journal_role(journal, user, :admin)
      end

      include_examples "person who can administer the journal (journal admin)"
    end

    context "who administers a journal, but not this journal" do
      let(:other_journal) do
        FactoryGirl.create(:journal, :with_roles_and_permissions)
      end

      before do
        assign_journal_role(other_journal, user, :admin)
      end

      include_examples "person who cannot administer the journal"
    end
  end
end
