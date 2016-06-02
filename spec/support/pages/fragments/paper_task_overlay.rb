class PaperTaskOverlay < Page
  def open_task
    element.find(heading_selector).click

    session.wait_for_condition do
      element.all(".task-loading").length == 0
    end
  end

  private

  def heading_selector
    '.task-disclosure-heading'
  end
end
