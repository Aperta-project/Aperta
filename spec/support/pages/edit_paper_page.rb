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

class EditPaperPage < Page
  include ActionView::Helpers::JavaScriptHelper

  path :edit_paper
  text_assertions :paper_title, '#paper-title'
  text_assertions :journal, '.paper-journal'

  def initialize element = nil
    find '.manuscript-container'
    super
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

  def visit_task_manager
    click_link 'Workflow'
    TaskManagerPage.new
  end

  def title=(val)
    find('#paper-title').set(val)
  end

  def abstract=(val)
    # find('#paper-title').set(val)
    raise NotImplementedError, "TODO: The UI on paper#edit needs to be implemented"
  end

  def body=(string)
    code = <<HERE
     var surf = ve.instances[0].getModel();
     var doc = surf.getDocument();
     var l = doc.getData().length;
     var range = new ve.Range(0, l);
     var clearTransaction = ve.dm.Transaction.newFromRemoval(doc, range, true);
     surf.change(clearTransaction);
     var newData = '#{string}'.split('');
     newTransaction = ve.dm.Transaction.newFromInsertion(doc, 0, newData);
     surf.change(newTransaction);
HERE
    page.execute_script code
  end

  def body
    find('.ve-ce-documentNode').text
  end

  def has_body_text?(text)
    find('.ve-ce-documentNode').has_text?(text)
  end

  def journal
    find(:css, '.paper-journal').text
  end

  def title
    find(:css, '#paper-title').text
  end

  def cards
    {
      metadata: all('#paper-metadata-tasks .card-content').map(&:text),
      assigned: all('#paper-assigned-tasks .card-content').map(&:text),
      editor: all('#paper-editor-tasks .card-content').map(&:text)
    }
  end

  def paper_type
    select = find('#paper_paper_type')
    select.find("option[value='#{select.value}']").text
  end

  def paper_type=(value)
    select = find('#paper_paper_type')
    select.select value
  end

  def start_writing
    find(".edit-paper-button").click
    expect(self).to have_css('.edit-paper-prompt', text: 'STOP WRITING')
  end

  def stop_writing
    find(".edit-paper-button").click
    expect(self).to have_css('.edit-paper-prompt', text: 'START WRITING')
  end

  def submit
    click_on "Submit"
    SubmitPaperOverlay.new
  end

  def css
    find('#paper-body')['style']
  end

  private

  def abstract_node
    find(:css, '#paper-abstract')
  end
end
