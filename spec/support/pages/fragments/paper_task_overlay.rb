class PaperTaskOverlay < Page
  def toggle
    element.find(heading_selector).click

    # this was taking more than the default on some runs
    wait_for_ajax(session, timeout: 20)
  end

  private

  def heading_selector
    '.task-disclosure-heading'
  end
end
