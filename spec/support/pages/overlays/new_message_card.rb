class NewMessageCardOverlay < CardOverlay


  def participants=(users)
    users.map(&:full_name).each { |name| select_from_chosen name, class: 'participant-select' }
  end

  def participants
    expect(page).to have_css '.participants'
    all('.participant .user-thumbnail').map { |e| e["alt"] }
  end

  def subject
    find('main > h1').text
  end

  def subject=(new_text)
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

end
