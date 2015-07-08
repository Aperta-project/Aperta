require 'rails_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks, :with_valid_plos_author, creator: user }

    before do
      make_user_paper_admin(user, paper)

      login_as user
      visit "/"

      click_link(paper.title)
    end

    scenario "Author edits paper", selenium: true do
      # editing the paper
      edit_paper = EditPaperPage.new
      edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
      edit_paper.body = "Contrary to popular belief"
      edit_paper.save
      edit_paper.reload

      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper).to have_body_text("Contrary to popular belief")
    end
  end
end
