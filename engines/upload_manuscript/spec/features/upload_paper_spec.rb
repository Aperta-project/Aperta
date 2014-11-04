require 'spec_helper'

feature "Upload paper", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author uploads paper in Word format", selenium: true do
    expect(DownloadManuscriptWorker).to receive(:perform_async) do |manuscript_id, url|
      paper.manuscript.update status: "done"
      paper.update title: "This is a Title About Turtles", body: "And this is my subtitle"
    end

    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card('Upload Manuscript').upload_word_doc

    expect(page).to have_no_css('.overlay.in')
    expect(edit_paper).to have_paper_title("This is a Title About Turtles")
    expect(edit_paper).to have_body_text("And this is my subtitle")
    expect(edit_paper.view_card 'Upload Manuscript').to be_completed
  end
end
