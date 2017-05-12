class TechCheckOverlay < CardOverlay
  include RichTextEditorHelpers

  def create_author_changes_card
    click_send_changes_button
    wait_for_editors
    set_rich_text(editor: 'author-changes-letter', text: 'First round author changes')
    click_send_changes_button
    expect_author_changes_saved
  end

  def expect_author_changes_saved
    expect(page).to have_content('Author Changes Letter has been Saved')
  end

  def display_letter
    find(".task-main-content .button-primary").click
  end

  def letter_text
    wait_for_editors
    get_rich_text(editor: 'author-changes-letter')
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
