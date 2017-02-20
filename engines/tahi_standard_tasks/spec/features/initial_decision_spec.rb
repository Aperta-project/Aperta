require 'rails_helper'

feature 'Initial Decision', js: true, sidekiq: :inline! do
  given(:admin) { FactoryGirl.create(:user, :site_admin) }
  given(:paper) do
    FactoryGirl.create :paper_with_task,
      :with_integration_journal,
      :initially_submitted_lite,
      task_params: {
        title: 'Initial Decision',
        type: 'TahiStandardTasks::InitialDecisionTask'
      }
  end

  background do
    login_as(admin, scope: :user)
    Page.view_task paper.tasks.first
  end

  context 'with a non-submitted Paper' do
    given(:paper) do
      FactoryGirl.create :paper_with_task,
        :with_integration_journal,
        task_params: {
          title: 'Initial Decision',
          type: 'TahiStandardTasks::InitialDecisionTask'
        }
    end

    scenario 'Participant cannot register a decision on the paper' do
      expect(page).to_not have_selector(
        '.send-email-action',
        text: 'REGISTER DECISION AND EMAIL THE AUTHOR'
      )
    end
  end

  scenario 'Registers a decision on the paper' do
    expect(TahiStandardTasks::InitialDecisionMailer)
      .to receive_message_chain(:delay, :notify)
    choose('Invite for full submission')
    find('.decision-letter-field').set('Accepting this because I can')
    wait_for_ajax

    # Expect the radio button and textfield to persist across reload
    visit current_path
    expect(find('input[value=invite_full_submission]')).to be_checked
    expect(find('.decision-letter-field').value).to eq('Accepting this because I can')

    find('.send-email-action').click
    expect(page).to have_selector('.rescind-decision', text: 'A decision of')
    expect(page).to have_selector(".task-is-completed")
    expect(first('.decision-letter-field')).to be_disabled
    expect(first('input[type=radio]')).to be_disabled
  end
end
