class PaperPage < Page
  path :paper

  def navigate_to_task_manager
    click_link 'Task Manager'
    TaskManagerPage.new
  end

  def title
    find("#paper-title").text
  end
end
