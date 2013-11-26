class PageNotReady < Capybara::ElementNotFound; end

class EditSubmissionPage < Page
  class Declaration
    def initialize element
      @element = element
    end

    def answer
      @element.find('textarea').value
    end

    def answer= value
      id = @element.find('textarea')[:id]
      @element.fill_in id, with: value
    end
  end

  class AuthorsOverlay
    def initialize element
      @element = element
    end

    def dismiss
      @element.all('.close-overlay').first.click
    end

    def add_author author
      @element.click_on "Add new"
      @element.fill_in "First name", with: author[:first_name]
      @element.fill_in "Last name", with: author[:last_name]
      @element.fill_in "Email", with: author[:email]
      @element.fill_in "Affiliation", with: author[:affiliation]
      @element.click_on "done"
    end
  end

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
    page.execute_script "CKEDITOR.instances.abstract_editable.setData('#{escape_javascript val}')"
  end

  def body=(val)
    page.execute_script "CKEDITOR.instances.body_editable.setData('#{escape_javascript val}')"
  end

  def authors_overlay &block
    find('#authors').click
    overlay = AuthorsOverlay.new find('#overlay')
    overlay.instance_eval &block
    overlay.dismiss
  end

  def authors
    find('#authors').text
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

  def declarations
    all('.declaration').map { |d| Declaration.new d }
  end

  def save_declarations
    click_on 'Save declarations'
  end

  def save
    current_path = page.current_path
    click_on 'Save'
    find('body').synchronize do
      raise PageNotReady if page.current_path == current_path
    end
    DashboardPage.new
  end

  def upload_word_doc
    click_on "Upload Manuscript"
    attach_file 'Upload Word Document', Rails.root.join('spec/fixtures/about_turtles.docx')
    click_on "Upload File"
    self
  end

  def submit
    click_on "Submit"
    SubmitPaperPage.new
  end

  private

  def abstract_node
    find(:css, '#abstract_editable')
  end

  def body_node
    find(:css, '#body_editable')
  end
end
