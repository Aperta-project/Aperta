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
    journal_page.view_card 'EDIT EPUB CSS' do |overlay|
      overlay.css = 'body: { background-color: red; }'
      overlay.save
    end

    journal_page.view_card 'Edit EPUB CSS' do |overlay|
      expect(overlay.css).to eq('body: { background-color: red; }')
    end

    journal_page.reload

    journal_page.view_card 'Edit EPUB CSS' do |overlay|
      expect(overlay.css).to eq('body: { background-color: red; }')
    end
  end
end
