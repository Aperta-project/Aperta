require 'rails_helper'

feature 'Accordion cards', js: true do
  let(:admin) { FactoryGirl.create :user, :site_admin }

  let(:author) { create :user, first_name: 'Author' }
  let!(:paper) {
    FactoryGirl.create(
      :paper_with_task,
      :with_integration_journal,
      task_params: { type: 'Task' },
      creator: author)
  }

  before do
    paper.tasks.each { |t| t.add_participant(author) }
  end

  context 'As a participant' do
    scenario 'opens card content on click', js: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"
      find('.task-disclosure-heading').click
      expect(page).to have_css('.task-main-content')
    end

    scenario 'closes card content on click', js: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"
      find('.task-disclosure-heading').click
      expect(page).to have_css('.task-main-content')
      find('.task-disclosure-heading').click
      expect(page).not_to have_css('.task-main-content')
    end

    pending 'does not crash Ember on double click', js: true do
      login_as(author, scope: :user)
      visit "/papers/#{paper.id}"
      # TODO: Fix this test, and the underlying code.
      # Chris Westra writes: In short we have a bunch of async stuff that gets
      # kicked off when you open the accordion. We don't properly account for
      # cases where the user clicks to close the accordion before the async
      # stuff is complete, at least not in some cases.
      find('.task-disclosure-heading').double_click
      find('.task-disclosure-heading').click
      expect(page).to have_css('.task-main-content')
    end
  end
end
