class PageNotReady < Capybara::ElementNotFound; end

class DeclarationFragment < PageFragment
  def answer
    find('textarea').value
  end

  def answer= value
    id = find('textarea')[:id]
    fill_in id, with: value
    find('label').click # blur the textarea
  end
end

class PaperPage < Page
  include ActionView::Helpers::JavaScriptHelper

  path :root
  text_assertions :paper_title, '#control-bar-paper-title'
  text_assertions :journal, '.paper-journal'

  def initialize element = nil
    find '.manuscript'
    super
  end

  def view_task(task, overlay_class=nil)
    name = ''
    element = nil

    if task.class == String
      element = find('.task-disclosure', text: task)
    else
      name = task.type.gsub(/.+::/,'').underscore.dasherize
      element = find(".#{name}")
    end

    fragment_class = overlay_class ? overlay_class : PaperTaskOverlay

    fragment = fragment_class.new(element)

    fragment.open_task
    fragment
  end

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def show_contributors
    reload
    downloads_link.click
    contributors_link.click
    click_contributors_link
    AddCollaboratorsOverlay.new(find('.show-collaborators-overlay'))
  end

  def click_contributors_link
    add_contributors_link.click
  end

  def contributors_link
    find '#nav-collaborators'
  end

  def downloads_link
    find '#nav-downloads'
  end

  def add_contributors_link
    find '#nav-add-collaborators'
  end

  def recent_activity_button
    first(:css, '#nav-recent-activity')
  end

  def version_button
    first(:css, '#nav-versions')
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
    find('#paper-body')
  end

  def versioned_body
    find('#paper-body')
  end

  def view_versions
    version_button.click
  end

  def select_viewing_version(version)
    power_select('.paper-viewing-version', version.version_string)
  end

  def select_comparison_version(version)
    power_select('.paper-comparison-version', version.version_string)
  end

  def has_body_text?(text)
    find('#paper-body').has_text?(text)
  end

  def loading_paper?
    has_css?('.progress-spinner-message')
  end

  # Use this method instead of negating `loading_paper?`
  # expect(page).to_not be_loading_paper will only return `false` after
  # the default capyabara wait expires, adding an extra 4 seconds to a passing test
  def not_loading_paper?
    has_no_css?('.progress-spinner-message')
  end

  def journal
    find(:css, '.paper-journal')
  end

  def title
    find('#paper-title')
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

  def withdraw_paper
    find('.more-dropdown-menu').click
    find('.withdraw-link').click

    expect(page).to have_css('.paper-withdraw-wrapper')
    within '.paper-withdraw-wrapper' do
      find('textarea.withdraw-reason').set 'I really decided not to publish'
      find('button.withdraw-yes').click
    end

    expect(page).to have_css(
      '.withdrawal-banner',
      text: /This paper has been withdrawn from.*and is in View Only mode/
    )
  end

  def css
    find('.manuscript')['style']
  end

  private

  def abstract_node
    find(:css, '#paper-abstract')
  end
end
