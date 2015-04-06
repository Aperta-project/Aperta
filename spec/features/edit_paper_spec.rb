require 'rails_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks, submitted: false, creator: user }

    before do
      make_user_paper_admin(user, paper)

      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user

      click_link(paper.title)
    end

    scenario "Author edits paper and metadata cards", selenium: true do
      # editing the paper
      edit_paper = EditPaperPage.new
      edit_paper.start_writing
      edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
      edit_paper.body = "Contrary to popular belief"
      edit_paper.stop_writing

      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper).to have_body_text("Contrary to popular belief")
      expect(edit_paper.cards[:metadata]).to match_array ['Upload Manuscript', 'Add Authors', 'Upload Figures', 'Supporting Info']
      expect(edit_paper.cards[:assigned]).to include 'Tech Check', 'Assign Admin'
      expect(edit_paper).to have_css('a.button--disabled')

      # completing the metadata cards
      edit_paper.cards[:metadata].each do |card|
        edit_paper.view_card card do |overlay|
          overlay.mark_as_complete
        end
      end
      expect(edit_paper).to_not have_css('a.button--disabled')
    end
  end

  context "As an Editor, with reviewers assigned" do
    let(:paper) { FactoryGirl.create :paper_with_phases, submitted: false, creator: user }
    let!(:reviewer_card) { paper.phases.first.tasks.create!(title: "ReviewMe", role: "reviewer") }

    before do
      make_user_paper_editor(user, paper)
      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user
    end

    scenario "the reviewer task is displayed" do
      click_link(paper.title)
      edit_paper = EditPaperPage.new
      expect(edit_paper.cards[:editor]).to include('ReviewMe')
    end
  end
end
