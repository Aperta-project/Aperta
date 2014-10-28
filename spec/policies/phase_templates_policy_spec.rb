require 'spec_helper'

describe PhaseTemplatesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:manuscript_manager_template) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let(:phase_template) { FactoryGirl.create(:phase_template, manuscript_manager_template: manuscript_manager_template) }
  let(:policy) { PhaseTemplatesPolicy.new(current_user: user, phase_template: phase_template) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer phase templates"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot administer phase templates"
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can administer phase templates"
  end
end
