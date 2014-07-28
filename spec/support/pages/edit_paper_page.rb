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

  def initialize element = nil
    expect(page).to have_css('h2#paper-title')
    super
  end

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def show_collaborators
    collaborators_link.click
    AddCollaboratorsOverlay.new(find('.show-collaborators-overlay'))
  end

  def collaborators_link
    find('a.add-collaborators')
  end

  def visit_task_manager
    click_link 'Manuscript Manager'
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

  def authors
    find('#paper-authors').text
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
      assigned: all('#paper-assigned-tasks .card-content').map(&:text)
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

  def submit
    click_on "Submit"
    SubmitPaperPage.new
  end

  def css
    find('#paper-body')['style']
  end

  private

  def abstract_node
    find(:css, '#paper-abstract')
  end
end
