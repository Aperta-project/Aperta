class PaperTaskOverlay < Page
  def open_task
    element.find(heading_selector).click
    # Wait to load
    expect(page).not_to have_css(".task-loading")
  end

  private

  def heading_selector
    '.task-disclosure-heading'
  end
end
