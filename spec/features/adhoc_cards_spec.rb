require 'rails_helper'

feature 'Adhoc cards', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let(:paper) do
    FactoryGirl.create :paper_with_task,
                       task_params: { type: 'Task' },
                       creator: author
  end
  let(:overlay) { AdhocOverlay.new }

  before do
    paper.tasks.each { |t| t.add_participant(author) }
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  context 'As a participant' do
    scenario 'uploads an image to ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      within('.attachment-item') do
        expect(page).to have_css('.file-link', text: 'yeti.jpg')
      end
    end

    scenario 'replaces an attachment on ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')
      overlay.replace_attachment('yeti2.jpg')
      expect(page).to have_css('.file-link', text: 'yeti2.jpg')
    end

    scenario 'edits attachment caption on ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')

      fill_in('attachment-caption', with: 'Great caption')
      expect(find_field('attachment-caption').value).to eq('Great caption')
    end

    scenario 'deletes attachment from an ad-hoc card' do
      overlay.upload_attachment('yeti.jpg')
      find('.file-link', text: 'yeti.jpg')
      find('.delete-attachment').click
      expect(page).not_to have_css('.attachment-item')
    end
  end
end
