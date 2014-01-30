class PaperPage < Page
  path :paper

  def navigate_to_task_manager
    click_link 'Task Manager'
    TaskManagerPage.new
  end

  def title
    find("#paper-title").text
  end

  def register_decision_overlay &block
    click_on 'Register Decision'
    overlay = RegisterDecisionOverlay.new find('#new-overlay')
    if block_given?
      block.call overlay
      overlay.dismiss
    else
      overlay
    end
  end
end
