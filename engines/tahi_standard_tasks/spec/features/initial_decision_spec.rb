require 'rails_helper'
include RichTextEditorHelpers

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
    text = 'Accepting this because I can'
    expect(TahiStandardTasks::InitialDecisionMailer)
      .to receive_message_chain(:delay, :notify)
    choose('Invite for full submission')
    wait_for_editors
    set_rich_text(editor: 'decision-letter-field', text: text)
    wait_for_ajax

    # Expect the radio button and textfield to persist across reload
    visit current_path
    wait_for_editors
    expect(find('input[value=invite_full_submission]')).to be_checked

    contents = get_rich_text(editor: 'decision-letter-field')
    expect(contents).to eq("<p>#{text}</p>")

    find('.send-email-action').click
    expect(page).to have_selector('.rescind-decision', text: 'A decision of')
    expect(page).to have_selector(".task-is-completed")
    expect(first('input[type=radio]')).to be_disabled
  end
end
