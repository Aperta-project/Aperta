require 'spec_helper'

feature "Manuscript Manager Templates", js: true do
  let(:admin) { FactoryGirl.create :user, :admin }
  let(:journal) { FactoryGirl.create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  describe "Adding phases" do
    scenario "Adding a phase" do
      mmt_page = ManuscriptManagerTemplatePage.visit(journal)
      mmt_page.add_new_template
      phase = mmt_page.find_phase 'New Phase'
      phase.rename 'F1rst Ph4ze'
      expect { phase.add_phase }.to change { mmt_page.phases.count }.by(1)
    end
  end
end


