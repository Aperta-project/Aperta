require 'rails_helper'

feature 'Cover Letter Task', js: true, selenium: true do
  let(:author) { FactoryGirl.create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
                       :with_integration_journal,
                       creator: author,
                       task_params: {
                         title: 'Cover Letter',
                         type: 'TahiStandardTasks::CoverLetterTask',
                         old_role: 'author'
                       }
  end

  before do
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  scenario 'Uploading an  attachment' do
    expect(page).to have_css('.attachment-manager')
    within '.attachment-manager' do
      expect(page).to have_content('Please select a file.')
      expect(page).to have_content('UPLOAD FILE')

      expect(DownloadAdhocTaskAttachmentWorker).to receive(:perform_async)
      file_path = Rails.root.join('spec/fixtures/about_turtles.docx')
      attach_file 'file', file_path, visible: false

      expect(page).to have_css('.attachment-item')
      expect(page).to have_no_content('UPLOAD FILE')
    end
  end

  scenario 'finishes the cover letter and save it' do
    expect(page).to have_css('.edit-cover-letter')
    within '.edit-cover-letter' do
      find('.cover-letter-field').set('Hello World')
      click_button 'Save'
    end
    expect(page).to_not have_css('.edit-cover-letter')
    expect(page).to have_css('.preview-cover-letter')

    within '.preview-cover-letter' do
      expect(page).to have_content 'Hello World'
      click_button 'Make Changes'
    end

    expect(page).to have_css('.edit-cover-letter')
  end
end
