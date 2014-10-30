require 'spec_helper'

describe Admin::JournalsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { Admin::JournalsPolicy.new(current_user: user, journal: journal) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer the journal"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot administer the journal"
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can administer the journal"
  end
end
