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

  def initialize element = nil
    expect(page).to have_css('h2#paper-title')
    super
  end

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def navigate_to_task_manager
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
    page.evaluate_script 've.instances[0].getModel().getDocument().getText()'
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

  def abstract
    abstract_node.text
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
    wait_for_pjax
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
end
