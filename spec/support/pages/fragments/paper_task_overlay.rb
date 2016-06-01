class PaperTaskOverlay < Page
  def toggle
  begin
    element.find(heading_selector).click
    wait_for_ajax(session, timeout: 20)
  rescue Exception => ex
    binding.pry
    puts
  end
  end

  private

  def heading_selector
    '.task-disclosure-heading'
  end
end
