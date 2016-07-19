class CardOverlay < Page
  path :root

  def dismiss
    session.all('.overlay .overlay-close-button').first.click
    synchronize_no_content!("CLOSE")
  end

  text_assertions :assignee, '.chosen-assignee.chosen-container', ->(name){ name.upcase }

  def assignee
    all('.chosen-assignee.chosen-container').first
  end

  def assignee=(name)
    select_from_chosen name, class: 'chosen-assignee'
  end

  def title
    find('.overlay-body-title')
  end

  def body
    find('main > p')
  end

  def mark_as_complete
    find('.task-not-completed').click
    expect_task_to_be_completed
  end

  def completed?
    has_css?('.task-is-completed')
  end

  # This method takes advantage of Capybara's default wait time to ensure
  # that the checkbox is in the state we want. Without expecting the state
  # Capybara would return the checkbox right away since it is on the page.
  # By expecting the state in the checkbox selector Capybara handles all
  # of the waiting and retries which helps us avoid sleep calls in our code.
  def expect_task_to_be_incomplete
    expect(self).to have_selector('.task-not-completed')
  end

  def expect_task_to_be_completed
    expect(self).to have_selector('.task-is-completed')
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
    expect(page).to have_css('.new-comment-field')
    page.execute_script('$(".new-comment-field").trigger("focus")')
    expect(page).to have_css(".new-comment-submit-button", visible: true)
    find('.new-comment-field').set(new_message)
    find('.new-comment-submit-button', text: "POST MESSAGE").click
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
