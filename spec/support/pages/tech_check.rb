class TechCheckOverlay < CardOverlay
  def create_author_changes_card
    click_send_changes_button
    fill_in 'author-changes-letter', with: 'First round author changes'
    click_send_changes_button
  end

  def expect_author_changes_saved
    expect(page).to have_content('Author Changes Letter has been Saved')
  end

  def expect_task_to_be_completed
    expect(page).to have_css('button.task-is-completed')
  end

  def display_letter
    find(".task-main-content .button-primary").click
  end

  def letter
    find("textarea[name='author-changes-letter']")
  end

  def click_autogenerate_email_button
    # find("button#autogenerate-email").click
    click_button 'Auto-generate Text'
  end

  private

  def click_send_changes_button
    click_button 'Send Changes to Author'
  end
end
