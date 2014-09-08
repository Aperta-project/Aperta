class PaperPage < Page
  path :edit_paper

  def initialize(element = nil)
    expect(page).to have_css('#paper-body', wait: 4)
    super
  end

  def visit_task_manager
    click_link 'Manuscript Manager'
    TaskManagerPage.new
  end

  def title
    find("#paper-title").text
  end

  def css
    find('#paper-body')['style']
  end
end
