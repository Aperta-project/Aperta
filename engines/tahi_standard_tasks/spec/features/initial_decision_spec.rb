require 'rails_helper'

feature 'Initial Decision', js: true do
  given(:admin) { FactoryGirl.create(:user, site_admin: true) }
  given(:paper) do
    FactoryGirl.create :paper_with_task,
                       publishing_state: 'initially_submitted',
                       task_params: {
                         title: 'Initial Decision',
                         type: 'TahiStandardTasks::InitialDecisionTask',
                         old_role: 'editor' }
  end

  background do
    login_as(admin, scope: :user)
    visit "/papers/#{paper.id}/tasks/#{paper.tasks.first.id}"
  end

  context 'with a non-submitted Paper' do
    given(:paper) do
      FactoryGirl.create :paper_with_task,
                         task_params: {
                           title: 'Initial Decision',
                           type: 'TahiStandardTasks::InitialDecisionTask',
                           old_role: 'editor' }
    end

    scenario 'Participant registers a decision on the paper' do
      expect(page).to have_selector('.alert-warning', text: 'A decision '\
        'cannot be registered at this time. The manuscript is not in a '\
        'submitted state.')
      expect(page).to have_selector('.button--disabled', text: 'REGISTER '\
        'DECISION AND EMAIL THE AUTHOR')
    end
  end

  scenario 'Registers a decision on the paper' do
    choose('Invite for full submission')
    find('.decision-letter-field').set('Accepting this because I can')
    find('.send-email-action').click
    expect(page).to have_selector('.alert', text: 'An initial decision of')
    expect(find('.task-completed')).to be_checked
    expect(first('.decision-letter-field')).to be_disabled
    expect(first('input[type=radio]')).to be_disabled
  end

  scenario 'Persist the decision radio button' do
    choose('Invite for full submission')
    find('.decision-letter-field').set('Accepting this because I can')
    find('.send-email-action').click
    expect(page).to have_selector('.alert', text: 'An initial decision of')

    visit current_path # Revisit

    expect(find('input[value=invite_full_submission]')).to be_checked
  end
end
