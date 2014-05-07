require 'spec_helper'

feature "Add contributing authors", js: true do
  let(:author) { create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author specifies contributing authors" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Add Authors' do |overlay|
      overlay.add_author first_name: 'Neils', last_name: 'Bohr', affiliation: 'University of Copenhagen', email: 'neils@bohr.com'
      overlay.add_author first_name: 'Nikola', last_name: 'Tesla', affiliation: 'Wardenclyffe'
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
