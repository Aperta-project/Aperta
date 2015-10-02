require 'rails_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks, :with_valid_author, creator: user }

    before do
      make_user_paper_admin(user, paper)

      login_as(user, scope: :user)
      visit "/"

      click_link(paper.title)
    end

    scenario "Author edits paper", selenium: true do
      # editing the paper
      edit_paper = PaperPage.new
      edit_paper.start_editing
      edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
      edit_paper.body = "Contrary to popular belief"
      # check if changes are applied
      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper.has_body_text?("Contrary to popular belief")).to be(true)
      edit_paper.save
      edit_paper.reload
      # check if changes are persisted
      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper.has_body_text?("Contrary to popular belief")).to be(true)
    end
  end
end
