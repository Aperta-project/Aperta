require 'spec_helper'

feature "Financial Disclosures", js: true do
  let(:submitter) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, user: submitter) }
  let!(:task) { FactoryGirl.create(:financial_disclosure_task, paper: paper) }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in submitter
  end

  scenario "first funder" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card(task.title) do |overlay|
      expect(overlay.received_no_funding).to be_checked
      expect(overlay).to_not have_content('.question-dataset')
      overlay.received_funding.click
      expect(overlay.dataset).to be_visible
    end
  end

  scenario "adding an author" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card(task.title) do |overlay|
      overlay.received_funding.click
      overlay.add_author("Oscar", "Grouch")
      expect(overlay).to have_selected_authors("Oscar Grouch")
    end
  end

  scenario "removing a funder" do
    funder = task.funders.create!(name: "Monsanto")

    edit_paper = EditPaperPage.visit paper
    edit_paper.view_card(task.title) do |overlay|
      overlay.received_funding.click
      expect(overlay.received_funding).to be_checked
      overlay.remove_funder
      expect(overlay.received_no_funding).to be_checked
      expect { StandardTasks::Funder.find(funder.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
