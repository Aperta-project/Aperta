require 'rails_helper'

feature 'Ethics Task', js: true do
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

  def view_ethics_card_on_the_manuscript_page
    visit "/papers/#{paper.id}"
    page = DashboardPage.new
    page.view_card_in_task_sidebar 'Ethics Statement'
  end

  def view_ethics_card_directly
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.last.id}"
  end

  background do
    login_as(author, scope: :user)
  end

  scenario 'It shows 3 questions' do
    view_ethics_card_on_the_manuscript_page
    expect(page).to have_selector('.question-text', count: 3)

    view_ethics_card_directly
    expect(page).to have_selector('.question-text', count: 3)
  end

  feature 'Animal research question' do
    scenario 'have a sub-question permit' do
      view_ethics_card_on_the_manuscript_page
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_field('ethics--animal_subjects--field_permit')
        end
      end
    end

    scenario 'have a sub-question upload ARRIVE guidelines' do
      view_ethics_card_on_the_manuscript_page
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_css('.attachment-manager')
        end
      end
    end

    scenario 'Uploading an attachment' do
      view_ethics_card_on_the_manuscript_page
      within '.question-text', text: 'animal research' do
        within(:xpath, '..') do
          choose('Yes')
          expect(page).to have_css('.attachment-manager')
          expect(page).to have_content('We encourage authors to comply with')
          expect(page).to have_content('UPLOAD ARRIVE CHECKLIST')

          expect(DownloadAttachmentWorker).to receive(:perform_async)
          file_path = Rails.root.join('spec/fixtures/about_turtles.docx')
          attach_file 'file', file_path, visible: false

          expect(page).to have_css('.attachment-item')
          expect(page).to have_no_content('UPLOAD ARRIVE CHECKLIST')
        end
      end
    end
  end
end
