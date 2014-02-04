require 'spec_helper'

feature "Editing paper", js: true do
  include ActionView::Helpers::JavaScriptHelper

  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author edits paper" do
    edit_paper = EditPaperPage.visit paper
    # edit_paper.short_title = "lorem-ipsum"
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.abstract = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
    edit_paper.body = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"
    sleep 1

    dashboard_page = edit_paper.save.navigate_to_dashboard
    expect(dashboard_page.submissions).to include "Lorem Ipsum Dolor Sit Amet"

    edit_paper = EditPaperPage.visit paper
    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    # expect(edit_paper.abstract).to match /Lorem Ipsum is simply dummy text/
    expect(edit_paper.body).to eq "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"
  end

  scenario "Author uploads paper in Word format" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.upload_manuscript_overlay.upload_word_doc

    expect(edit_paper.title).to eq "This is a Title About Turtles"
    expect(edit_paper.body).to match /And this is my subtitle/
    # expect(edit_paper.upload_manuscript_overlay).to be_completed
  end

  scenario "Author makes declarations" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.declarations_overlay do |overlay|
      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to be_empty
      expect(ethics_declaration.answer).to be_empty
      expect(competing_interest_declaration.answer).to be_empty

      funding_disclosure.answer = "Yes"
      ethics_declaration.answer = "No"
      competing_interest_declaration.answer = "Sometimes"

      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to eq "Yes"
      expect(ethics_declaration.answer).to eq "No"
      expect(competing_interest_declaration.answer).to eq "Sometimes"

      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    edit_paper.reload
    edit_paper.declarations_overlay do |overlay|
      funding_disclosure, ethics_declaration, competing_interest_declaration = overlay.declarations
      expect(funding_disclosure.answer).to eq "Yes"
      expect(ethics_declaration.answer).to eq "No"
      expect(competing_interest_declaration.answer).to eq "Sometimes"
      expect(overlay).to be_completed
    end
    sleep 0.1
  end

  scenario "Author uploads figures" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.uploads_overlay do |overlay|
      overlay.attach_figure
      expect(overlay).to have_image 'yeti.tiff'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    edit_paper.reload

    edit_paper.uploads_overlay do |overlay|
      expect(overlay).to have_image('yeti.tiff')
      expect(overlay).to be_completed
    end
    sleep 0.1
  end

  scenario "Author specifies contributing authors" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.authors_overlay do |overlay|
      overlay.add_author first_name: 'Neils', last_name: 'Bohr', affiliation: 'University of Copenhagen', email: 'neils@bohr.com'
      overlay.add_author first_name: 'Nikola', last_name: 'Tesla', affiliation: 'Wardenclyffe'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    expect(edit_paper.authors).to eq "Neils Bohr, Nikola Tesla"

    edit_paper.reload

    expect(edit_paper.authors).to eq "Neils Bohr, Nikola Tesla"

    edit_paper.authors_overlay do |overlay|
      expect(overlay).to be_completed
    end
    sleep 0.1
  end
end
