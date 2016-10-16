class PaperWorkflowPage < Page
  def expect_activity_item_with_text(text)
    expect(page).to have_css(
      '.activity-feed-overlay-message',
      text: text
    )
  end

  def view_recent_activity
    within '#control-bar' do
      find('#nav-recent-activity').click
    end
  end
end
