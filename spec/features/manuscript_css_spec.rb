require 'spec_helper'

feature "Manuscript CSS", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, manuscript_css: "background: magenta;" }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: false, short_title: 'foo bar', creator: author }
  let(:submitted_paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: true, short_title: 'submitted foo bar', creator: author }

  before do
    submitted_paper.tasks.metadata.update_all completed: true
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "CSS is applied when editing a paper" do
    edit_paper = EditPaperPage.visit paper
    expect(edit_paper.css).to match /magenta/
  end

  context "when the paper is submitted" do
    scenario "CSS is applied when viewing a paper" do
      paper_page = PaperPage.visit submitted_paper
      expect(paper_page.css).to match /magenta/
    end
  end
end
