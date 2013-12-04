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
      @element.find('label').click # blur the textarea
      sleep 0.5 # and wait for the AJAX request to finish
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

  class UploadOverlay
    def initialize element
      @element = element
    end

    def dismiss
      @element.all('.close-overlay').first.click
    end

    def has_image? image_name
      @element.has_selector? "img[src$='#{image_name}']"
    end

    def attach_figure
      @element.session.execute_script "$('#figure_attachment').css('position', 'relative')"
      @element.attach_file('figure_attachment', Rails.root.join('spec', 'fixtures', 'yeti.tiff'), visible: false)
      @element.session.execute_script "$('#figure_attachment').css('position', 'absolute')"
    end

    def upload_figures
      @element.click_button "Upload Figure"
    end
  end

  class DeclarationsOverlay
    def initialize element
      @element = element
    end

    def dismiss
      @element.all('.close-overlay').first.click
    end

    def declarations
      @element.all('.declaration').map { |d| Declaration.new d }
    end

    def save_declarations
      @element.click_on 'Save declarations'
    end
  end

  include ActionView::Helpers::JavaScriptHelper

  path :edit_paper

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def short_title=(val)
    page.execute_script "$('#short-title-editable').text('#{val}')"
  end

  def title=(val)
    page.execute_script "$('#title-editable').text('#{val}')"
  end

  def abstract=(val)
    page.execute_script "CKEDITOR.instances['abstract-editable'].setData('#{escape_javascript val}')"
  end

  def body=(val)
    page.execute_script "CKEDITOR.instances['body-editable'].setData('#{escape_javascript val}')"
  end

  def uploads_overlay &block
    click_on 'Upload Figures'
    overlay = UploadOverlay.new find('#overlay')
    if block_given?
      block.call overlay
      overlay.dismiss
    else
      overlay
    end
  end

  def authors_overlay &block
    find('#authors').click
    overlay = AuthorsOverlay.new find('#overlay')
    block.call overlay
    overlay.dismiss
  end

  def authors
    find('#authors').text
  end

  def title
    find(:css, '#title-editable').text
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

  def declarations_overlay &block
    click_on 'Declarations'
    overlay = DeclarationsOverlay.new find('#overlay')
    block.call overlay
    overlay.dismiss
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
    find(:css, '#abstract-editable')
  end

  def body_node
    find(:css, '#body-editable')
  end
end
