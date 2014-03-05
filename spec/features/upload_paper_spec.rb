require 'spec_helper'

feature "Upload paper", js: true do
  include ActionView::Helpers::JavaScriptHelper

  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author uploads paper in Word format" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card('Upload Manuscript').upload_word_doc

    expect(edit_paper.title).to eq "This is a Title About Turtles"
    expect(edit_paper.body).to match /And this is my subtitle/
    # expect(edit_paper.view_card 'Upload Manuscript').to be_completed
  end
end
