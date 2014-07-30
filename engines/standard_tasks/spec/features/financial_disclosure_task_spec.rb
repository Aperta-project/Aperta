require 'spec_helper'

feature "Financial Disclosures", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    paper.phases.last.tasks.create!(type: "StandardTasks::FinancialDisclosureTask", assignee_id: author.id)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "first funder" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Financial Disclosure' do |overlay|
      expect(overlay.received_no_funding).to be_checked
      expect(overlay).to_not have_content('.question-dataset')
      overlay.received_funding.click
      expect(overlay.dataset).to be_visible
    end
  end

  scenario "adding an author" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Financial Disclosure' do |overlay|
      overlay.received_funding.click
      overlay.add_author("Oscar", "Grouch")
      expect(overlay.selected_authors).to include("Oscar Grouch")
    end
  end
end
