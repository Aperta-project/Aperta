require 'rails_helper'

feature 'Authors card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_task,
      :with_integration_journal,
      task_params: { type: "TahiStandardTasks::AuthorsTask" },
      creator: author
    )
  end

  before do
    paper.tasks.each { |t| t.add_participant(author) }
  end

  context 'As an author' do
    scenario 'validates the authors card on completion', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      find_button('Add a New Author').click
      find('#add-new-individual-author-link').click
      find('.author-first').send_keys('first')
      find('.author-last').send_keys('last')
      find('.author-email').send_keys('email@email.email')
      find('.author-title').send_keys('title')
      find('.author-department').send_keys('department')
      find_button('done').click
      expect(overlay).to have_css('.author-task-item-view .author-email', text: 'email@email.email')
      expect(overlay).to be_uncompleted
      overlay.dismiss

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      expect(overlay).to be_uncompleted
    end

    scenario 'validates group authors on completion', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      find_button('Add a New Author').click
      find('#add-new-group-author-link').click
      find('.contact-first').send_keys('first')
      find('.contact-last').send_keys('last')
      find('.contact-email').send_keys('email@email.email')
      find_button('done').click
      expect(overlay).to have_css('.author-task-item-view .author-email', text: 'email@email.email')
      expect(overlay).to be_uncompleted
      overlay.dismiss

      overlay = Page.view_task_overlay(paper, paper.tasks.first)
      expect(overlay).to be_uncompleted
    end
  end
end
