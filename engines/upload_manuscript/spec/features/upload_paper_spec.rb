require 'rails_helper'

feature "Upload paper", js: true, selenium: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, creator: author, journal: journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  skip "Author uploads paper in Word format" do
    expect(DownloadManuscriptWorker).to receive(:perform_async) do |manuscript_id, url|
      paper.manuscript.update(status: "done")
      paper.update(title: "This is a Title About Turtles", body: "And this is my subtitle")
    end

    edit_paper_page = EditPaperPage.visit(paper.reload)

    edit_paper_page.view_card('Upload Manuscript').upload_word_doc

    expect(page).to have_no_css('.overlay.in')
    expect(edit_paper_page).to have_paper_title("This is a Title About Turtles")
    expect(edit_paper_page).to have_body_text("And this is my subtitle")
    edit_paper_page.view_card 'Upload Manuscript' do |card|
      expect(card.completed_checkbox).to be_checked
    end
  end
end
