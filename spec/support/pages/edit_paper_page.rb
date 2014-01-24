class PageNotReady < Capybara::ElementNotFound; end

class DeclarationFragment < PageFragment
  def answer
    find('textarea').value
  end

  def answer= value
    id = find('textarea')[:id]
    fill_in id, with: value
    find('label').click # blur the textarea
    wait_for_pjax
  end
end

class EditPaperPage < Page
  include ActionView::Helpers::JavaScriptHelper

  path :edit_paper

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def navigate_to_task_manager
    click_link 'Task Manager'
    TaskManagerPage.new
  end

  def short_title=(val)
    page.execute_script "$('#paper-short-title').text('#{val}')"
  end

  def title=(val)
    page.execute_script "$('#paper-title').text('#{val}')"
  end

  def abstract=(val)
    page.execute_script "CKEDITOR.instances['paper-abstract'].setData('#{escape_javascript val}')"
  end

  def body=(val)
    page.execute_script "CKEDITOR.instances['paper-body'].setData('#{escape_javascript val}')"
  end

  def uploads_overlay &block
    click_on 'Upload Figures'
    overlay = UploadOverlay.new find('#new-overlay')
    if block_given?
      block.call overlay
      overlay.dismiss
    else
      overlay
    end
  end

  def authors_overlay &block
    find('#paper-authors').click
    overlay = AuthorsOverlay.new find('#new-overlay')
    block.call overlay
    overlay.dismiss
  end

  def authors
    find('#paper-authors').text
  end

  def journal
    find(:css, '#paper-journal').text
  end

  def title
    find(:css, '#paper-title').text
  end

  def abstract
    abstract_node.text
  end

  def body
    body_node.text
  end

  def paper_type
    select = find('#paper_paper_type')
    select.find("option[value='#{select.value}']").text
  end

  def paper_type=(value)
    select = find('#paper_paper_type')
    select.select value
    wait_for_pjax
  end

  def upload_manuscript_overlay &block
    click_on 'Upload Manuscript'
    UploadManuscriptOverlay.new find('#new-overlay')
  end

  def declarations_overlay &block
    click_on 'Declarations'
    overlay = DeclarationsOverlay.new find('#new-overlay')
    block.call overlay
    overlay.dismiss
  end

  def save
    click_on 'Save'
    self
  end

  def submit
    click_on "Submit"
    SubmitPaperPage.new
  end

  private

  def abstract_node
    find(:css, '#paper-abstract')
  end

  def body_node
    find(:css, '#paper-body')
  end
end
