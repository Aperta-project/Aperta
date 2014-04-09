class NewAdhocCardOverlay < CardOverlay


  def title
    find('main > h1').text
  end

  def title=(new_text)
    fill_in 'task-title-field', with: new_text
  end

  def body
    find('#task_body').text
  end

  def body=(new_text)
    fill_in 'task_body', with: new_text
  end

  def create
    find('a', text: 'CREATE CARD').click
  end

  def assignee=(name)
    select_from_chosen name, class: 'select-assignee'
  end

end
