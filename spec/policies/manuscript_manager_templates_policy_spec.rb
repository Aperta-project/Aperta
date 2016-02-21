require 'rails_helper'

describe ManuscriptManagerTemplatesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:manuscript_manager_template) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let(:policy) { ManuscriptManagerTemplatesPolicy.new(current_user: user, manuscript_manager_template: manuscript_manager_template) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer manuscript manager templates"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot administer manuscript manager templates"
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can administer manuscript manager templates"
  end
end
