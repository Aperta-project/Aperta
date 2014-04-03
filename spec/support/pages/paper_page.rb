class PaperPage < Page
  path :edit_paper

  def navigate_to_task_manager
    click_link 'Manuscript Manager'
    wait_for_turbolinks
    TaskManagerPage.new
  end

  def title
    find("#paper-title").text
  end
end
