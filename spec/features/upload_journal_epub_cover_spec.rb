require 'rails_helper'

feature "Upload default ePub cover for journal", js: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  scenario "uploading an ePub cover" do
    # removed because changing in next PR with backgrounding
  end
end
