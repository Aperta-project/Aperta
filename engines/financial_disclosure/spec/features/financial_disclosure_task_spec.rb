require 'spec_helper'

feature "Financial Disclosures", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    paper.phases.last.tasks.create!(type: "FinancialDisclosure::Task")
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "first funder" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Financial Disclosure' do |overlay|
      expect(overlay.received_no_funding).to be_checked
      expect(overlay).to_not have_content('.dataset')
      overlay.received_funding.click
      expect(overlay.dataset).to be_visible
    end
  end

  scenario "navigate to authors card and back" do
    pending "Waiting on discussion about how to visually implement adding authors to funding sources"
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Financial Disclosure' do |overlay|
      overlay.received_funding.click
      find('a', text: 'Add author').click
      expect(page).to have_content 'Add Authors'
      all('.overlay-close-button').first.click
      expect(page).to have_content 'Financial Disclosures'
    end
  end
end
