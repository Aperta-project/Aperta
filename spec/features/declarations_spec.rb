require 'spec_helper'

feature "Make declarations", js: true do
  include ActionView::Helpers::JavaScriptHelper

  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author makes declarations" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Declarations' do |overlay|
      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to be_empty
      expect(ethics_declaration.answer).to be_empty
      expect(competing_interest_declaration.answer).to be_empty

      funding_disclosure.answer = "Yes"
      ethics_declaration.answer = "No"
      competing_interest_declaration.answer = "Sometimes"

      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to eq "Yes"
      expect(ethics_declaration.answer).to eq "No"
      expect(competing_interest_declaration.answer).to eq "Sometimes"

      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    edit_paper.reload
    edit_paper.view_card 'Declarations' do |overlay|
      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to eq "Yes"
      expect(ethics_declaration.answer).to eq "No"
      expect(competing_interest_declaration.answer).to eq "Sometimes"
      expect(overlay).to be_completed
    end
  end
end
