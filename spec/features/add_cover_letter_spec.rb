require 'rails_helper'

feature 'Adding cover letter', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper_with_task, task_params: { type: "TahiStandardTasks::CoverLetterTask" }, creator: author) }
  let(:letter_body)  { "Foo Bar, Hello World" }

  before do
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  context 'As an author' do
    scenario 'finishes the cover letter and save it', selenium: true do
      expect(page).to have_css('.edit-cover-letter')

      within '.edit-cover-letter' do
        find('.cover-letter-field').set(letter_body)
        click_button 'Save'
      end
      expect(page).to_not have_css('.edit-cover-letter')
      expect(page).to have_css('.preview-cover-letter')

      within '.preview-cover-letter' do
        expect(page).to have_content letter_body
        click_button 'Make Changes'
      end

      expect(page).to have_css('.edit-cover-letter')
    end
  end
end
