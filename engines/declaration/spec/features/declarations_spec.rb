require 'spec_helper'

feature "Make declarations", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author makes declarations" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Enter Declarations' do |overlay|
      expect(overlay.disclosure_declaration.answer).to be_empty
      expect(overlay.ethics_declaration.answer).to be_empty
      expect(overlay.interests_declaration.answer).to be_empty

      overlay.disclosure_declaration.answer = "Yes"
      overlay.ethics_declaration.answer = "No"
      overlay.interests_declaration.answer = "Sometimes"

      expect(overlay.disclosure_declaration.answer).to eq("Yes")
      expect(overlay.interests_declaration.answer).to eq("Sometimes")
      expect(overlay.ethics_declaration.answer).to eq("No")

      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

  end
end
