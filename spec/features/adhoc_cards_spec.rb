require 'rails_helper'

feature 'Adhoc cards', js: true do
  let(:admin) { FactoryGirl.create :user, :site_admin }

  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper_with_task, task_params: { type: "Task" }, creator: author) }

  before do
    paper.tasks.each { |t| t.add_participant(author) }
  end

  context 'As a participant' do
    scenario "uploads an image to ad-hoc card", selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"

      overlay = AdhocOverlay.new
      overlay.upload_attachment("yeti.jpg")
      expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
      expect(page).to have_css(".thumbnail-preview img[src*='#{Attachment.last.file.versions[:preview].path}']")

      find(".thumbnail-preview").hover
      find(".view-attachment-detail").click
      expect(page).to have_css(".big-preview img[src*='#{Attachment.last.file.versions[:detail].path}']")
    end

    scenario "replaces an attachment on ad-hoc card", selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"

      overlay = AdhocOverlay.new
      overlay.upload_attachment("yeti.jpg")
      expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
      expect(page).to have_css(".thumbnail-preview img[src*='#{Attachment.last.file.versions[:preview].path}']")

      overlay.replace_attachment("yeti2.jpg")
      expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
    end

    scenario "edits attachment info on ad-hoc card", selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"

      overlay = AdhocOverlay.new
      overlay.upload_attachment("yeti.jpg")
      expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
      expect(page).to have_css(".thumbnail-preview img[src*='#{Attachment.last.file.versions[:preview].path}']")

      all(".fa-pencil").last.click
      find(".attachment-title-field").set("Super Great Title")
      find(".attachment-caption-field").set("Super great desription.")

      find(".attachment-save-button").click
      expect(page).to have_css(".title", text: 'Super Great Title')
      expect(page).to have_css(".caption", text: 'Super great desription.')
    end

    scenario "deletes attachment from an ad-hoc card", selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"

      overlay = AdhocOverlay.new
      overlay.upload_attachment("yeti.jpg")
      expect(page).to have_css(".download-link a[href*='#{Attachment.last.file.path}']")
      expect(page).to have_css(".thumbnail-preview img[src*='#{Attachment.last.file.versions[:preview].path}']")

      find(".fa-trash").click
      find(".attachment-delete-button").click

      expect(page).not_to have_css(".thumbnail-preview")
    end
  end
end
