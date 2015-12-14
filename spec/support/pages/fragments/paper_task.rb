class PaperTask < Page
  def toggle
    element.find(heading_selector).click
    wait_for_ajax
  end

  private

  def heading_selector
    '.task-disclosure-heading'
  end
end
