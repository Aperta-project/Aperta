require 'support/pages/card_overlay'

# Task Overlay for: Changes For Author
class ChangesForAuthorOverlay < CardOverlay
  def expect_to_see_change_list
    expect(page).to have_content('First round author changes')
  end
end
