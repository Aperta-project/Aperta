class MessageCardOverlay < CardOverlay

  def add_participants(users)
    users.map(&:full_name).each do |name|
      select_from_chosen name, class: 'participant-select', skip_synchronize: true
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

  def load_comments
    find('.load-all-comments').click
  end

  def verify_comment_count(expected_count)
    expect(comments.count).to eq(expected_count)
  end

  def omitted_comment_count
    find('a.load-all-comments').text.scan(/\d/).first.to_i
  end

  def unread_comments
    all('li.unread')
  end

end
