class MessageCardOverlay < CardOverlay


  def add_participants(users)
    users.map(&:full_name).each { |name| select_from_chosen name, from: 'Participants' }
  end

  def participants
    all('#participants .user-thumbnail').map { |e| e["data-user-name"] }
  end

  def subject
    find('main > h1').text
  end

  def comments
    expect(page).to have_css('.message-comment')
    all('.message-comment')
  end

  def post_message(new_message)
    fill_in 'message-body', with: new_message
    click_button 'Post Message'
    expect(page).to have_content new_message
  end

end
