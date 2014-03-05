class NewMessageCardOverlay < CardOverlay


  def participants=(users)
    users.map(&:full_name).each { |name| select_from_chosen name, from: 'Participants' }
  end

  def participants
    all('#participants .user-thumbnail').map { |e| e["data-user-name"] }
  end

  def subject
    find('main > h1').text
  end

  def subject=(new_text)
    fill_in 'message-subject', with: new_text
  end

  def body
    find('.comment-body').text
  end

  def body=(new_text)
    fill_in 'message-body', with: new_text
  end

  def create
    click_button 'Create Card'
  end

end
