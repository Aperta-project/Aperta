require 'spec_helper'

feature "Add contributing authors", js: true do
  let(:submitter) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: submitter }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in submitter
  end

  scenario "Author specifies contributing authors" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Add Authors' do |overlay|
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
    let!(:author) { FactoryGirl.create :author, paper: paper }

    scenario "editing" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card 'Add Authors' do |overlay|
        overlay.edit_author author.first_name,
          last_name: 'rommel',
          email: 'ernie@berlin.de'
        visit current_url
        within '.authors-overlay-list' do
          expect(page).to have_content "ernie@berlin.de"
          expect(page).to have_content "rommel"
        end
      end
    end

    scenario "deleting" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card 'Add Authors' do |overlay|
        overlay.delete_author author.first_name
        within '.authors-overlay-list' do
          expect(page).to have_no_content author.first_name
        end
      end
    end
  end
end
