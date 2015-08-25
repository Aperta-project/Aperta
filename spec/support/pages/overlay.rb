class CardOverlay < Page
  path :root

  def dismiss
    session.all('.overlay .overlay-close-button').first.click
    synchronize_no_content!("CLOSE")
  end

  text_assertions :assignee, '.chosen-assignee.chosen-container', ->(name){ name.upcase }

  def assignee
    all('.chosen-assignee.chosen-container').first.text
  end

  def assignee=(name)
    select_from_chosen name, class: 'chosen-assignee'
  end

  def title
    find('main h1').text
  end

  def body
    find('main > p').text
  end

  def completed_checkbox
    find(checkbox_selector)
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

  def participants
    expect(page).to have_css '.select2-choices'
    all('.select2-choices .user-thumbnail-small').map { |e| e["alt"] }
  end

  def has_participants?(*participants)
    participants.all? do |participant|
      page.has_css?(".select2-choices .user-thumbnail-small[alt='#{participant.full_name}']")
    end
  end

  def has_no_participants?(*participants)
    participants.all? do |participant|
      page.has_no_css?(".select2-choices .user-thumbnail-small[alt='#{participant.full_name}']")
    end
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
    find('.new-comment-field').set(new_message)
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

  private

  def checkbox_selector
    'footer input[type=checkbox]'
  end
end
