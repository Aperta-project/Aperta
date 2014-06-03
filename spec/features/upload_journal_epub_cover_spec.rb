require 'spec_helper'

feature "Upload default ePub cover for journal", js: true do
  let(:admin) { create :user, :admin }
  let!(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  scenario "uploading an ePub cover" do
    journal_page
    journal_page.upload_epub_cover
    expect(journal_page.epub_cover).to eq('yeti.jpg')

    journal_page.reload
    expect(journal_page.epub_cover).to eq('yeti.jpg')
  end
end
