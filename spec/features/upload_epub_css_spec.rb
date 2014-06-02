require 'spec_helper'

feature 'Upload default ePub CSS to journal' do
  let(:admin) { create :user, :admin }
  let!(:journal) { create :journal }
  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario 'uploading an ePub CSS source' do
    journal_page
    journal_page.upload_css
    expect(journal_page.epub_cover).to eq('yeti.jpg')

  end
end
