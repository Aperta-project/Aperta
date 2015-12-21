class InitialTechCheckOverlay < CardOverlay
  def current_round
    find('.initial-tech-check-round-number').text.match(/\d/).to_s.to_i
  end

  def create_author_changes_card
    click_button 'Write Author Changes Letter'
    fill_in 'author-changes-letter', with: 'First round author changes'
    click_button 'Create Author Changes Card'
    page.has_content? 'Edit Author Changes Letter'
  end

  def display_letter
    find(".task-main-content .button-primary").click
  end

  def letter
    find("textarea[name='author-changes-letter']")
  end

  def click_autogenerate_email_button
    find("button#autogenerate-email").click
  end
end
