require 'rails_helper'

feature "Upload paper", js: true, selenium: true, sidekiq: :inline! do
  let(:author) { FactoryGirl.create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      creator: author,
      task_params: {
        title: "Upload Manuscript",
        type: "TahiUploadManuscript::UploadManuscriptTask",
        role: "author"
      }
  end

  before do
    allow_any_instance_of(IhatJobRequest).to receive(:queue) do
      paper.create_manuscript(status: "done")
      paper.update(title: "This is a Title About Turtles", body: "And this is my subtitle")
    end

    login_as(author, scope: :user)
    visit "/"
  end

  scenario "Author uploads paper in Word format" do
    click_link paper.title
    edit_paper_page = PaperPage.new
    edit_paper_page.view_card('Upload Manuscript').upload_word_doc

    expect(page).to have_no_css('.overlay.in')
    expect(edit_paper_page).to have_paper_title("This is a Title About Turtles")
    expect(edit_paper_page.has_body_text?("And this is my subtitle")).to eq(true)
  end
end
