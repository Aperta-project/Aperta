require 'rails_helper'

feature 'Authors card', js: true do
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_phases, creator: author)
  end

  before do
    task = FactoryGirl.create(:authors_task, :with_loaded_card, paper: paper, phase: paper.phases.first)
    task.add_participant(author)
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

    scenario 'new authors go to bottom of the list', selenium: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"
      overlay = Page.view_task_overlay(paper, paper.tasks.first)

      find_button('Add a New Author').click
      find('#add-new-individual-author-link').click
      find('input.author-first').send_keys('First')
      find('input.author-email').send_keys('email@email.email')
      find_button('done').click

      find_button('Add a New Author').click
      find('#add-new-individual-author-link').click
      find('input.author-first').send_keys('Last')
      find('input.author-email').send_keys('email2@email.email')
      find_button('done').click
      assert_selector('.author-name', count: 2)
      expect(all(".ember-view.author-task-item .author-name").last).to have_text 'Last'
    end
  end
end
