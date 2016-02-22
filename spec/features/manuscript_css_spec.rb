require 'rails_helper'

feature "Manuscript CSS", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, manuscript_css: "background: magenta;" }

  before do
    paper
    login_as(author, scope: :user)
    visit "/"
    click_link(paper.title)
  end

  context "when editing the paper" do
    let(:paper) { FactoryGirl.create :paper, journal: journal, creator: author }

    scenario "CSS is applied when editing a paper" do
      edit_paper = PaperPage.new
      expect(edit_paper.css).to match /magenta/
    end
  end

  context "when the paper is submitted" do
    let(:paper) do
      FactoryGirl.create :paper, :submitted, journal: journal, creator: author
    end

    scenario "CSS is applied when viewing a paper" do
      paper_page = PaperPage.new
      expect(paper_page.css).to match /magenta/
    end
  end
end
