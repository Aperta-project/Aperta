require 'spec_helper'

feature "Add contributing authors", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_default_template }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: author }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author specifies contributing authors" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Add Authors' do |overlay|
      overlay.add_author({
        first_name: 'Neils',
        middle_initial: 'B.',
        last_name: 'Bohr',
        title: 'Soup of the day',
        department: 'Underwhere?',
        affiliation: 'University of Copenhagen',
        email: 'neils@bohr.com'
      })
      overlay.add_author({
        first_name: 'Nikola',
        last_name: 'Tesla',
        affiliation: 'Wardenclyffe',
        secondary_affiliation: 'University of Copenhagen',
      })
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    expect(edit_paper.authors).to eq "Neils Bohr, Nikola Tesla"

    edit_paper.reload

    expect(edit_paper.authors).to eq "Neils Bohr, Nikola Tesla"

    edit_paper.view_card 'Add Authors' do |overlay|
      expect(overlay).to be_completed
    end
  end
end
