require 'rails_helper'

feature 'Authors card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) { FactoryGirl.create(:paper_with_task, task_params: { type: "TahiStandardTasks::AuthorsTask" }, creator: author) }

  before do
    paper.tasks.each { |t| t.add_participant(author) }
  end

  context 'As an author' do
    scenario 'validates the authors card on completion', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      find_button('Add a New Author').click
      find('.author-first').send_keys('first')
      find('.author-last').send_keys('last')
      find('.author-email').send_keys('email@email.email')
      find('.author-title').send_keys('title')
      find('.author-department').send_keys('department')
      find_button('done').click
      overlay.expect_task_to_be_incomplete
      overlay.dismiss

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      overlay.expect_task_to_be_incomplete
    end
  end
end
