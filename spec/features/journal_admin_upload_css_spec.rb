require 'rails_helper'

feature 'Upload default CSS on journal admin page', js: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal, :with_roles_and_permissions }
  let(:css) { 'body { background-color: red; }' }

  before do
    login_as(admin, scope: :user)
    visit '/'
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let!(:journal_page) { admin_page.visit_journal(journal) }

  scenario 'uploading an ePub CSS source' do
    click_button('edit-epub-css')
    find('#edit-epub-css-textarea').set css
    click_on 'Save'
    expect(page).to have_css('.epub-css.save-status', text: 'Saved')
    expect(journal.reload.epub_css).to eq(css)
    expect(journal_page).to have_no_application_error
  end

  scenario 'uploading a PDF CSS source' do
    click_button('edit-pdf-css')
    find('#edit-pdf-css-textarea').set css
    click_on 'Save'
    expect(page).to have_css('.pdf-css.save-status', text: 'Saved')
    expect(journal.reload.pdf_css).to eq(css)
    expect(journal_page).to have_no_application_error
  end

  scenario 'uploading a manuscript CSS source' do
    click_button('edit-manuscript-css')
    find('#edit-manuscript-css-textarea').set css
    click_on 'Save'
    expect(page).to have_css('.manuscript-css.save-status', text: 'Saved')
    expect(journal.reload.manuscript_css).to eq(css)
    expect(journal_page).to have_no_application_error
  end
end
