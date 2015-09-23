require 'rails_helper'

feature 'Adding cover letter', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper)  { create :paper, :with_tasks, :with_valid_author, creator: author }
  let(:letter_body)  { "Foo Bar, Hello World" }

  before do
    login_as(author, scope: :user)
    visit "/"
  end

  context 'As an author' do
    scenario 'finishes the cover letter and save it', selenium: true do
      click_link(paper.title)
      expect(page).to have_content 'Cover Letter'

      find('.card-content', text: 'Cover Letter').click
      expect(page).to have_css('.edit-cover-letter')

      within '.edit-cover-letter' do
        find('.taller-textarea').set(letter_body)
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
