require 'spec_helper'

feature "Editing paper", js: true do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: false, short_title: 'foo bar', user: user }

  context "As an author" do
    before do
      make_user_paper_admin(user, paper)

      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user
    end

    scenario "Author edits paper and metadata cards", selenium: true do
      edit_paper = EditPaperPage.visit paper
      edit_paper.start_writing
      edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
      edit_paper.body = "Contrary to popular belief"
      edit_paper.stop_writing

      sleep 1
      edit_paper.reload

      expect(edit_paper).to have_paper_title("Lorem Ipsum Dolor Sit Amet")
      expect(edit_paper).to have_body_text("Contrary to popular belief")
      expect(edit_paper.cards[:metadata]).to match_array ['Upload Manuscript', 'Add Authors', 'Upload Figures', 'Supporting Info']
      expect(edit_paper.cards[:assigned]).to include 'Tech Check', 'Assign Admin'
    end

    scenario "Author completes all metadata cards", selenium: true do
      edit_paper = EditPaperPage.visit paper
      expect(edit_paper).to have_css('a.button--disabled')
      edit_paper.cards[:metadata].each do |card|
        edit_paper.view_card card do |overlay|
          overlay.mark_as_complete
        end
      end
      expect(edit_paper).to_not have_css('a.button--disabled')
    end
  end

  context "As an Editor, with reviewers assigned" do
    before do
      make_user_paper_editor(user, paper)

      sign_in_page = SignInPage.visit
      sign_in_page.sign_in user

      phase = paper.phases.last
      phase.tasks.create! title: "ReviewMe", role: "reviewer"
    end

    scenario "the reviewer task is displayed" do
      edit_paper = EditPaperPage.visit paper
      expect(edit_paper.cards[:editor]).to include('ReviewMe')
    end
  end
end
