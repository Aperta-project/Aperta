class PaperPage < Page
  path :edit_paper

  def visit_task_manager
    click_link 'Manuscript Manager'
    TaskManagerPage.new
  end

  def title
    find("#paper-title").text
  end
end
