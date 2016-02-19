require 'rails_helper'

feature 'Ethics Task', js: true, selenium: true do
  given(:author) { FactoryGirl.create :user }
  given!(:paper) do
    FactoryGirl.create :paper_with_task,
                       :with_integration_journal,
                       creator: author,
                       task_params: {
                         title: 'Ethics Statement',
                         type: 'TahiStandardTasks::EthicsTask',
                         old_role: 'author'
                       }
  end

  background do
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  scenario 'It shows 3 questions' do
    expect(page).to have_selector('.question-text', count: 3)
  end

  feature 'Animal research question' do
    scenario 'have a sub-question permit' do
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_field('ethics--animal_subjects--field_permit')
        end
      end
    end

    scenario 'have a sub-question upload ARRIVE guidelines' do
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_css('.attachment-manager')
        end
      end
    end

    scenario 'Uploading an attachment' do
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_css('.attachment-manager')
          expect(page).to have_content('We encourage authors to comply with')
          expect(page).to have_content('UPLOAD ARRIVE CHECKLIST')

          expect(DownloadQuestionAttachmentWorker).to receive(:perform_async)
          file_path = Rails.root.join('spec/fixtures/about_turtles.docx')
          attach_file 'file', file_path, visible: false

          expect(page).to have_css('.attachment-item')
          expect(page).to have_no_content('UPLOAD ARRIVE CHECKLIST')
        end
      end
    end
  end
end
