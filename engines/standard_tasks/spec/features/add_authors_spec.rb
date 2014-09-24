require 'spec_helper'

feature "Add contributing authors", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: author }
  let(:author_group) { paper.author_groups.first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author specifies contributing authors" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Add Authors' do |overlay|
      overlay.add_author('First Author',
                         first_name: 'Neils',
                         middle_initial: 'B.',
                         last_name: 'Bohr',
                         title: 'Soup of the day',
                         department: 'Underwhere?',
                         affiliation: 'University of Copenhagen',
                         email: 'neils@bohr.com'
                        )
      overlay.add_author( 'Second Author',
                         first_name: 'Nikola',
                         last_name: 'Tesla',
                         affiliation: 'Wardenclyffe',
                         secondary_affiliation: 'University of Copenhagen'
                        )
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end

  context "with an existing author" do
    let!(:existing_author) { create :author, author_group: author_group }

    scenario "editing" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card 'Add Authors' do |overlay|
        overlay.edit_author existing_author.first_name,
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
        overlay.delete_author existing_author.first_name
        within '.authors-overlay-list' do
          expect(page).to have_no_content existing_author.first_name
        end
      end
    end
  end

  describe "author groups" do
    scenario "adding author groups" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card 'Add Authors' do |overlay|
        expect {
          find(".add-group").click
        }.to change { overlay.author_groups.count }.by 1
      end
    end

    scenario "removing author groups" do
      paper.author_groups << AuthorGroup.ordinalized_create(paper_id: paper.id)
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card 'Add Authors' do |overlay|
        expect {
          find(".remove-group").click
        }.to change { overlay.author_groups.count }.by -1
      end
    end
  end
end
