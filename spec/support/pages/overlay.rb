class CardOverlay < Page
  path :paper_task

  def dismiss
    session.all('.overlay .overlay-close-button').first.click
    synchronize_no_content!("Close")
  end

  def assignee
    all('.chosen-assignee.chosen-container').first.text
  end

  def assignee=(name)
    select_from_chosen name, class: 'chosen-assignee'
  end

  def title
    find('main > h1').text
  end

  def body
    find('main > p').text
  end

  def mark_as_complete
    check "Completed"
    check "Completed" unless completed?
  end

  def completed?
    find(checkbox_selector).checked?
  end

  def view_paper
    find('a.overlay-paper-link').click
    PaperPage.new
  end

  private
  def checkbox_selector
    'footer input[type=checkbox]'
  end
end
