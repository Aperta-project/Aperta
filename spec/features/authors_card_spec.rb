require 'rails_helper'

feature 'Authors Task', js: true do
  let(:creator) { create :user, first_name: 'Author' }
  let!(:paper) do
    FactoryGirl.create(
      :paper,
      :with_tasks,
      :with_integration_journal,
      creator: creator
    )
  end
  let!(:authors_task) do
    paper.tasks_for_type('TahiStandardTasks::AuthorsTask').first
  end
  context 'As an author' do
    scenario 'validates the authors card on completion', selenium: true do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
      overlay = Page.view_task_overlay(paper, authors_task)
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

      overlay = Page.view_task_overlay(paper, authors_task)
      expect(overlay).to be_uncompleted
    end

    scenario 'validates group authors on completion', selenium: true do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"

      overlay = Page.view_task_overlay(paper, authors_task)
      find_button('Add a New Author').click
      find('#add-new-group-author-link').click
      find('.contact-first').send_keys('first')
      find('.contact-last').send_keys('last')
      find('.contact-email').send_keys('email@email.email')
      find_button('done').click
      expect(overlay).to have_css('.author-task-item-view .author-email', text: 'email@email.email')
      expect(overlay).to be_uncompleted
      overlay.dismiss

      overlay = Page.view_task_overlay(paper, authors_task)
      expect(overlay).to be_uncompleted
    end

    scenario 'new authors go to bottom of the list', selenium: true do
      login_as(creator, scope: :user)
      visit "/papers/#{paper.id}"
      overlay = Page.view_task_overlay(paper, authors_task)

      find_button('Add a New Author').click
      find('#add-new-individual-author-link').click
      find('.author-first').send_keys('First')
      find_button('done').click

      find_button('Add a New Author').click
      find('#add-new-individual-author-link').click
      find('.author-first').send_keys('Last')
      find_button('done').click

      last_author = find(:xpath, '//div[@class="ember-view author-task-item"][2]')
      expect(last_author).to have_text 'Last'
    end
  end
end
