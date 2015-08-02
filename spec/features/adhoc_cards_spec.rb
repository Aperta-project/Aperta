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
        overlay.attach_and_upload_file
        expect(page).to have_link("a", text: Attachment.last.filename)
      end
    end
  end
end
