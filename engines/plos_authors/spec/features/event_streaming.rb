require 'rails_helper'

feature "event streaming", js: true do
  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:paper) { FactoryGirl.create :paper, creator: user }
  let!(:plos_authors_task) { FactoryGirl.create(:plos_authors_task, phase: phase) }

  before do
    login_as user
    visit "/"
  end

  describe "plos authors task" do
    before do
      edit_paper_page = PaperPage.visit(paper)
      edit_paper_page.view_card(plos_authors_task.title)
    end

    scenario "displays event streamed plos author" do
      new_author = FactoryGirl.create(:plos_author, plos_authors_task: plos_authors_task)
      PlosAuthors::PlosAuthorsTask.last.update_attribute(:completed, true)
      expect(page).to have_css(".authors-overlay-item", text: new_author.first_name)
    end
  end
end
