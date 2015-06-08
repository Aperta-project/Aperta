require 'rails_helper'

feature "Adding cover letter", js: true do
  let(:author) { create :user, first_name: "Author" }
  let(:paper)  { create :paper, :with_tasks, :with_valid_plos_author, submitted: false, creator: author }

  context "As an author" do
    scenario "see the Cover Letter task card on the side", selenium: true do
      sign_in_page = SignInPage.visit
      sign_in_page.sign_in author

      click_link(paper.title)
      expect(page).to have_content 'Cover Letter'
    end
  end

  context "As an admin" do

  end
end
