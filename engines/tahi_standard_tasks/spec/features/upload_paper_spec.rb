require 'rails_helper'

feature "Upload paper", js: true, selenium: true, sidekiq: :inline! do
  let(:author) { FactoryGirl.create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      :with_integration_journal,
      creator: author,
      task_params: {
        title: "Upload Manuscript",
        type: "TahiStandardTasks::UploadManuscriptTask",
        old_role: "author"
      }
  end

  before do
    expect(DownloadManuscriptWorker).to receive(:perform_async)
    login_as(author, scope: :user)
    visit "/"
  end

  scenario "Author uploads paper in Word format" do
    overlay = Page.view_task_overlay(paper, paper.tasks.first)
    overlay.upload_word_doc

    wait_for_ajax

    visit "/papers/#{paper.id}"
    edit_paper_page = PaperPage.new

    expect(edit_paper_page).to be_loading_paper
  end
end
