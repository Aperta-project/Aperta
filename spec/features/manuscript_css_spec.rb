require 'rails_helper'

feature "Manuscript CSS", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, manuscript_css: "background: magenta;" }

  before do
    paper
    login_as author
    visit "/"
    click_link(paper.title)
  end

  context "when editing the paper" do
    let(:paper) { FactoryGirl.create :paper, journal: journal, short_title: 'foo bar', creator: author }

    scenario "CSS is applied when editing a paper" do
      edit_paper = PaperPage.new
      expect(edit_paper.css).to match /magenta/
    end
  end

  context "when the paper is submitted" do
    let(:paper) { FactoryGirl.create :paper, :submitted, journal: journal, short_title: 'submitted foo bar', creator: author }

    scenario "CSS is applied when viewing a paper" do
      paper_page = PaperPage.new
      expect(paper_page.css).to match /magenta/
    end
  end
end
