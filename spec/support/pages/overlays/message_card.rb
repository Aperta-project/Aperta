class MessageCardOverlay < CardOverlay
  text_assertions :subject, "main > h1"

  def add_participants(*users)
    users.map(&:full_name).each do |name|
      fill_in 'add_participant', with: name
      find('.tt-suggestion').click
      expect(page).to have_css ".participants [alt='#{name}']"
    end
  end

  def participants
    expect(page).to have_css '.participants'
    all('.participant .user-thumbnail').map { |e| e["alt"] }
  end

  def has_participants?(*participants)
    participants.all? do |participant|
      page.has_css?(".participant .user-thumbnail[alt='#{participant.full_name}']")
    end
  end

  def has_no_participants?(*participants)
    participants.all? do |participant|
      page.has_no_css?(".participant .user-thumbnail[alt='#{participant.full_name}']")
    end
  end

  def subject
    find('main > h1').text
  end

  def comments
    expect(page).to have_css('.message-comment')
    all('.message-comment')
  end

  def most_recent_comment
    find('.message-comment:last-of-type')
  end

  def has_last_comment_posted_by?(user)
    retry_stale_element do
      most_recent_comment.find('.comment-name').has_text?(user.full_name)
    end
  end

  def post_message(new_message)
    find("#comment-body").click
    fill_in 'comment-body', with: new_message
    find('.button-secondary', text: "POST MESSAGE").click
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
