class EditSubmissionPage < Page
  include ActionView::Helpers::JavaScriptHelper

  path :edit_paper

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def short_title=(val)
    page.execute_script "$('#short_title_editable').text('#{val}')"
  end

  def title=(val)
    page.execute_script "$('#title_editable').text('#{val}')"
  end

  def abstract=(val)
    abstract_node.click
    page.execute_script "$('#abstract_editable').text('#{escape_javascript val}')"
    abstract_node.synchronize { abstract == val }
  end

  def body=(val)
    body_node.click
    page.execute_script "$('#body_editable').text('#{escape_javascript val}')"
    body_node.synchronize { body == val }
  end

  def title
    find(:css, '#title_editable').text
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
  end

  def save
    click_on 'Save Paper'
    DashboardPage.new
  end

  def upload_word_doc
    click_on "Upload Manuscript"
    attach_file 'Upload Word Document', Rails.root.join('spec/fixtures/about_turtles.docx')
    click_on "Upload File"
    self
  end

  private

  def abstract_node
    find(:css, '#abstract_editable')
  end

  def body_node
    find(:css, '#body_editable')
  end
end
