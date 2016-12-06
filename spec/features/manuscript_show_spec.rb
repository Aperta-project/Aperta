require 'rails_helper'

feature 'Viewing manuscript control bar', js: true do
  before do
    login_as(user, scope: :user)
    visit "/papers/#{paper.id}"
  end

  context 'as an admin' do
    let(:user) { FactoryGirl.create :user, :site_admin }
    let(:paper) { FactoryGirl.create :paper, :with_integration_journal }

    scenario 'can view the Go to Workflow link' do
      expect(page).to have_css('#nav-workflow')
    end
  end

  context 'as an author' do
    let(:user) { FactoryGirl.create :user }
    let(:paper) do
      FactoryGirl.create :paper, :with_integration_journal, creator: user
    end

    scenario 'can not view the Go to Workflow link' do
      expect(page).to_not have_css('#nav-workflow')
    end

    scenario 'visit the paper by id instead of short_doi' do
      page = Page.new
      page.visit("/papers/#{paper.id}")
      expect(page.current_path).to eq("/papers/#{paper.short_doi}")
    end
  end
end
