require 'rails_helper'

feature 'Upload default CSS on journal admin page', js: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal }

  before do
    login_as(admin, scope: :user)
    visit "/"
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let!(:journal_page) { admin_page.visit_journal(journal) }

  scenario 'uploading an ePub CSS source' do
    css = 'body { background-color: red; }'
    journal_page.update_epub_css css
    expect(journal_page.epub_css_saved?).to eq(true)
    expect(journal_page.view_epub_css).to eq css
    expect(journal_page).to have_no_application_error
  end

  scenario 'uploading a manuscript CSS source' do
    css = 'body { background-color: red; }'
    journal_page.update_manuscript_css css
    expect(journal_page.manuscript_css_saved?).to eq(true)
    expect(journal_page.view_manuscript_css).to eq css
    expect(journal_page).to have_no_application_error
  end

  scenario 'uploading a PDF CSS source' do
    css = 'body { background-color: red; }'
    journal_page.update_pdf_css css
    expect(journal_page.pdf_css_saved?).to eq(true)
    expect(journal_page.view_pdf_css).to eq css
    expect(journal_page).to have_no_application_error
  end
end
