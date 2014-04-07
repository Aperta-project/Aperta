class MessageCardOverlay < CardOverlay

  def add_participants(users)
    users.map(&:full_name).each do |name|
      select_from_chosen name, class: 'participant-select'
      expect(page).to have_css ".participants [alt='#{name}']"
    end
  end

  def participants
    expect(page).to have_css '.participants'
    all('.participant .user-thumbnail').map { |e| e["alt"] }
  end

  def subject
    find('main > h1').text
  end

  def comments
    expect(page).to have_css('.message-comment')
    all('.message-comment')
  end

  def post_message(new_message)
    fill_in 'comment-body', with: new_message
    click_button 'Post Message'
    expect(page).to have_content new_message
  end

end
