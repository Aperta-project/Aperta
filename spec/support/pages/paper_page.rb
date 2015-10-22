class PageNotReady < Capybara::ElementNotFound; end

class DeclarationFragment < PageFragment
  def answer
    find('textarea').value
  end

  def answer= value
    id = find('textarea')[:id]
    fill_in id, with: value
    find('label').click # blur the textarea
    synchronize_content! "DISCLOSURE"
  end
end

class PaperPage < Page
  include ActionView::Helpers::JavaScriptHelper

  path :root
  text_assertions :paper_title, '#paper-title'
  text_assertions :journal, '.paper-journal'

  def initialize element = nil
    find 'article.manuscript'
    super
  end

  def find_card(text)
    find('.card-content', text: text)
  end

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def show_contributors
    downloads_link.click
    contributors_link.click
    add_contributors_link.click
    AddCollaboratorsOverlay.new(find('.show-collaborators-overlay'))
  end

  def contributors_link
    find '.contributors-link'
  end

  def downloads_link
    find '.downloads-link'
  end

  def add_contributors_link
    find '.contributors-add'
  end

  def version_button
    first(:css, '.versions-link')
  end

  def visit_task_manager
    click_link 'Workflow'
    TaskManagerPage.new
  end

  def title=(string)
    element = title
    element.send_keys = string
  end

  def abstract=(val)
    # find('#paper-title').set(val)
    raise NotImplementedError, "TODO: The UI on paper#edit needs to be implemented"
  end

  def body
    find('.paper-body')
  end

  def versioned_body
    find('#paper-body')
  end

  def has_body_text?(text)
    find('.paper-body').has_text?(text)
  end

  def journal
    find(:css, '.paper-journal')
  end

  def title
    find('#paper-title')
  end

  def cards
    {
      metadata: all('#paper-metadata-tasks .card-content').map(&:text),
      assigned: all('#paper-assigned-tasks .card-content').map(&:text),
      editor: all('#paper-editor-tasks .card-content').map(&:text)
    }
  end

  def paper_type
    find('#paper_paper_type').find("option[value='#{select.value}']")
  end

  def paper_type=(value)
    find('#paper_paper_type').select value
  end

  def save
    code = <<HERE
var editorController = Tahi.__container__.lookup("controller:paper/index/html-editor");
editorController.savePaper();
HERE
    page.execute_script code
  end

  def submit(&blk)
    click_on "Submit"
    SubmitPaperOverlay.new.tap do |overlay|
      if blk
        blk.call overlay
        wait_for_ajax
      end
    end
  end

  def css
    find('#paper-body')['style']
  end

  private

  def abstract_node
    find(:css, '#paper-abstract')
  end
end
