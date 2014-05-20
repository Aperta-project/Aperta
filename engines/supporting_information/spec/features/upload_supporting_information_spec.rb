require File.expand_path('../../../../../spec/spec_helper', __FILE__)

feature "Upload Supporting Information", js: true do
  let(:author) { create :user }
  let(:journal) { create :journal, :with_default_template }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: author }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author uploads supporting information" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Supporting Information' do |overlay|
      overlay.attach_file
      expect(overlay).to have_file 'yeti.tiff'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    edit_paper.reload

    edit_paper.view_card 'Supporting Information' do |overlay|
      expect(overlay).to have_file('yeti.tiff')
      expect(overlay).to be_completed
    end
  end
end
