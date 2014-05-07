require 'spec_helper'

feature "Upload paper", js: true, vcr: {cassette_name: 'upload_manuscript'} do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_default_template }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author uploads paper in Word format" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card('Upload Manuscript').upload_word_doc

    expect(page).to have_no_css('.overlay.in')
    expect(edit_paper.title).to eq "This is a Title About Turtles"
    expect(edit_paper.body).to match /And this is my subtitle/
    expect(edit_paper.view_card 'Upload Manuscript').to be_completed
  end
end
