require 'rails_helper'

feature "Add collaborating authors", js: true do
  let(:creator) { FactoryGirl.create :user }
  let!(:paper) { FactoryGirl.create :paper, creator: creator }
  let!(:task) { FactoryGirl.create(:plos_authors_task, title: "Authors", paper: paper) }


  before do
    task.participants << creator
    paper.paper_roles.create(user: creator, role: PaperRole::COLLABORATOR)
    login_as creator
    visit "/"
  end

  scenario "Author specifies contributing authors" do
    edit_paper = DashboardPage.new.view_submitted_paper paper

    edit_paper.view_card(task.title) do |overlay|
      overlay.add_author(first_name: 'Neils',
                         middle_initial: 'B.',
                         last_name: 'Bohr',
                         title: 'Soup of the day',
                         department: 'Underwhere?',
                         affiliation: 'University of Copenhagen',
                         email: 'neils@bohr.com')
      expect(overlay).to have_content "Neils B. Bohr"
    end
  end

  context "with an existing author" do
    let!(:author) { FactoryGirl.create :plos_author, paper: paper, plos_authors_task: task }

    scenario "editing", selenium: true do
      edit_paper = DashboardPage.new.view_submitted_paper paper
      edit_paper.view_card(task.title) do |overlay|
        overlay.edit_author author.first_name,
          last_name: 'rommel',
          email: 'ernie@berlin.de'
        overlay.reload
        within '.authors-overlay-list' do
          expect(page).to have_content "ernie@berlin.de"
          expect(page).to have_content "rommel"
        end
      end
    end

    scenario "validation on task completion", selenium: true do
      edit_paper = DashboardPage.new.view_submitted_paper paper
      edit_paper.view_card(task.title) do |overlay|
        overlay.edit_author author.first_name,
          email: 'invalid_email_string'
        overlay.mark_as_complete
        expect(page).to have_css(".add-author-form")
        within ".add-author-form" do
          expect(page).to have_content "needs to be a valid email address"
        end
      end
    end

    scenario "deleting", selenium: true do
      edit_paper = DashboardPage.new.view_submitted_paper paper
      edit_paper.view_card(task.title) do |overlay|
        overlay.delete_author author.first_name
        within '.authors-overlay-list' do
          expect(page).to have_no_content author.first_name
        end
      end
    end
  end
end
