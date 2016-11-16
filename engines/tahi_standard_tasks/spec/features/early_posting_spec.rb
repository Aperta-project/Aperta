require 'rails_helper'

feature 'Early Posting Task', js: true do
  given(:author) { FactoryGirl.create :user }
  given!(:paper) do
    FactoryGirl.create :paper_with_task,
                       :with_integration_journal,
                       creator: author,
                       task_params: {
                         title: 'Early Article Posting',
                         type: 'TahiStandardTasks::EarlyPostingTask'
                       }
  end

  def view_early_posting_card_on_the_manuscript_page
    visit "/papers/#{paper.id}"
    page = DashboardPage.new
    page.view_card_in_task_sidebar 'Early Article Posting'
  end

  def view_early_posting_card_directly
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.last.id}"
  end

  background do
    login_as(author, scope: :user)
  end

  scenario 'It shows 1 question', flaky: true do
    view_early_posting_card_on_the_manuscript_page
    expect(page).to have_selector('.question-checkbox', count: 1)

    view_early_posting_card_directly
    expect(page).to have_selector('.question-checkbox', count: 1)
  end
end
