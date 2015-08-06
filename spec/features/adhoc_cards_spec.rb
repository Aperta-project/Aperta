require 'rails_helper'

feature 'Adhoc cards', js: true do
  let(:admin) { FactoryGirl.create :user, :site_admin }

  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper_with_task, task_params: { type: "Task" }, creator: author) }

  before do
    paper.tasks.each{ |t| t.participants << author }
  end

  context 'As a participant' do
    scenario "uploads an image to ad-hoc card", selenium: true do
      login_as author
      visit "/papers/#{paper.id}"

      edit_paper = EditPaperPage.new
      edit_paper.view_card('Ad Hoc', AdhocOverlay) do |overlay|
        overlay.attach_and_upload_file("yeti.jpg")
        expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
        expect(page).to have_css(".thumbnail-preview img[src*='#{Attachment.last.file.versions[:preview].path}']")

        find(".thumbnail-preview").hover
        find(".view-attachment-detail").click
        expect(page).to have_css(".big-preview img[src*='#{Attachment.last.file.versions[:detail].path}']")
      end
    end
  end
end
