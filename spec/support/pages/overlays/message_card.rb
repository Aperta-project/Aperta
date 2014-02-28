class MessageCardOverlay < CardOverlay
  def participants=(users)
    users.map(&:full_name).each { |name| select_from_chosen name, from: 'Participants' }
  end

  def participants
    all('#participants .participant').map { |e| e["data-participant-name"] }
  end

  def subject
    find_field('message-subject').text
  end

  def subject=(new_text)
    fill_in 'message-subject', with: new_text
  end

  def body
    find_field('message-body').text
  end

  def body=(new_text)
    fill_in 'message-body', with: new_text
  end

  def create
    click_button 'Create Card'
  end

end
