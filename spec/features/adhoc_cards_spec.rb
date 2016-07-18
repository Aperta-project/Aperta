require 'rails_helper'

feature 'Adhoc cards', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let(:admin) { FactoryGirl.create :user, site_admin: true }
  let(:paper) do
    FactoryGirl.create :paper_with_task,
                       :with_integration_journal,
                       task_params: { type: 'Task' },
                       creator: author
  end
  let(:overlay) { AdhocOverlay.new }

  context 'As a participant' do
    before do
      paper.tasks.each { |t| t.add_participant(author) }
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
    end

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
      expect(page).to have_no_css('.attachment-item')
    end
  end

  context 'As someone who can manage email participants' do
    before do
      login_as(admin, scope: :user)
      visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
    end

    scenario 'allows sending email from ad-hoc card' do
      overlay.find('.fa-plus').click
      overlay.find('.adhoc-toolbar-item--email').click
      overlay.fill_in('Enter a subject', with: 'subject')
      overlay.find('.email-body').click
      overlay.find('.email-body').send_keys('body')
      overlay.find_all('.button-secondary', text: 'SAVE').first.click
      overlay.find('.email-send-participants').click
      overlay.find_all('.add-participant-button', text: '+').first.click
      overlay.find('.select2-input').send_keys('author')
      overlay.find('.select2-results').click
      overlay.find('.send-email-action').click

      expect(overlay).to have_text('Your email has been sent.')
    end
  end
end
