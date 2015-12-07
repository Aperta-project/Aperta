require 'rails_helper'

feature 'Authors card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }

  before do
    paper.tasks.each { |t| t.participants << author }
  end

  context 'As an author' do
    scenario 'validates the authors card on completion', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      edit_paper = PaperPage.new
      edit_paper.view_card('Authors', CardOverlay) do |overlay|
        find_button('Add a New Author').click
        find('.author-first').send_keys('first')
        find('.author-last').send_keys('last')
        find('.author-email').send_keys('email@email.email')
        find('.author-title').send_keys('title')
        find('.author-department').send_keys('department')
        find_button('done').click
        overlay.completed_checkbox.click
        sleep(2)

        expect(overlay.completed?).to eq(false)
        overlay.dismiss

        find_link('Authors').click
        expect(overlay.completed?).to eq(false)
      end
    end
  end
end
