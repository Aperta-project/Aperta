require 'spec_helper'

feature 'Upload default ePub CSS to journal', js: true do
  let(:admin) { create :user, :admin }
  let!(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let!(:journal_page) { admin_page.visit_journal(journal) }

  scenario 'uploading an ePub CSS source' do
    css = 'body { background-color: red; }'
    journal_page.update_epub_css css
    expect(journal_page.view_epub_css).to eq css
    expect(journal_page.epub_css_saved?).to eq(true)

    journal_page.reload
    expect(journal_page.view_epub_css).to eq css
  end
end
