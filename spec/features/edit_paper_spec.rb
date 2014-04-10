require 'spec_helper'

feature "Editing paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    make_user_admin(author)

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author edits paper and metadata cards" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.body = "Contrary to popular belief"

    dashboard_page = edit_paper.save
    edit_paper = EditPaperPage.visit paper

    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    expect(edit_paper.body).to eq "Contrary to popular belief"
    expect(edit_paper.cards[:metadata]).to match_array ['Upload Manuscript', 'Add Authors', 'Upload Figures', 'Enter Declarations']
    expect(edit_paper.cards[:assigned]).to include 'Tech Check', 'Assign Admin'
  end

  def make_user_admin(user)
    JournalRole.create! admin: true, journal: paper.journal, user: author
    paper_admin_task = paper.tasks.where(title: 'Assign Admin').first
    paper_admin_task.assignee = author
    paper_admin_task.save!
  end
end
