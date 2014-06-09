require 'spec_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: false, short_title: 'foo bar', user: author }

  before do
    make_user_paper_admin(author, paper)

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author edits paper and metadata cards" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.body = "Contrary to popular belief"

    dashboard_page = edit_paper.save
    edit_paper = EditPaperPage.visit paper

    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    expect(edit_paper.body).to eq "Contrary to popular belief"
    expect(edit_paper.cards[:metadata]).to match_array ['Upload Manuscript', 'Add Authors', 'Upload Figures', 'Enter Declarations', 'Supporting Information']
    expect(edit_paper.cards[:assigned]).to include 'Tech Check', 'Assign Admin'
  end

  scenario "Author completes all metadata cards" do
    edit_paper = EditPaperPage.visit paper
    expect(edit_paper).to have_css('a.disabled-button')
    edit_paper.cards[:metadata].each do |card|
      edit_paper.view_card card do |overlay|
        overlay.mark_as_complete
      end
      # rapidly transitioning from paper.edit to task and back
      # will break subsequent transitions to task.  we need a sleep
      # here for the time being.
      sleep 0.1

    end
    expect(edit_paper).to_not have_css('a.disabled-button')
  end

  scenario "author placeholder text" do
    edit_paper = EditPaperPage.visit paper
    expect(edit_paper.authors).to eq("Click here to add authors")
  end

  scenario "clicking the author text" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.find("#paper-authors").click
    expect(page).to have_content /add authors/i
  end
end
