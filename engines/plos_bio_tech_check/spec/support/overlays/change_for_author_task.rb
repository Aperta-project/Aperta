# Task Overlay for: Changes For Author

class ChangesForAuthorOverlay < CardOverlay
  def expect_to_see_change_list
    expect(page).to have_content('First round author changes')
  end

  def click_changes_have_been_made
    click_button 'These changes have been made'
  end
end
