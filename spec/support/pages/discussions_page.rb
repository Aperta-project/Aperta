class DiscussionsPage < Page
  def new_topic
    find(create_topic_button).click
    wait_for_ajax
  end

  def fill_in_topic
    find('input.discussion-topic-title-field').set('Great Title')
    find('.discussion-topic-comment-field').set('first!!')
  end

  def create_topic
    find('.discussions-show-content .button-primary').click
    wait_for_ajax
  end

  def click_topic
    find('a.discussions-index-topic').click
    wait_for_ajax
  end

  def expect_topic_created_succesfully(user)
    expect_view_topic
    user_name_in_comments(user, 1)
  end

  def expect_can_add_participant
    expect(page).to have_css(add_participant_button)
  end

  def expect_no_create_button
    expect(page).not_to have_css(create_topic_button)
  end

  def expect_no_at_mention_suggestions
    expect(page).to have_no_css(at_mention_suggestions)
  end

  def expect_at_mention_suggestion_count(count)
    expect(page).to have_css(at_mention_suggestions, count: count)
  end

  def expect_reply_count(count)
    expect(page).to have_css(discussion_replies, count: count)
  end

  def expect_view_topic
    expect(find('h1.discussions-show-title'))
    expect(find('.participant-selector'))
    expect(find('.discussions-show-form'))
  end

  def expect_reply_mentioning_user(by:, mentioned:)
    author = most_recent_reply.find('.comment-name')
    expect(author).to have_content(by.full_name)
    user_mention = most_recent_reply.find('.comment-body .discussion-at-mention')
    expect(user_mention).to have_content(mentioned.username)
  end

  def most_recent_reply
    all(discussion_replies).first
  end

  def add_reply
    find(new_comment_field).set('new reply')
    submit_comment
    wait_for_ajax
  end

  def submit_comment
    find(new_comment_field).send_keys(:tab)
    find('button.new-comment-submit-button').click
  end

  def add_reply_mentioning_user(mentioning_user, fragment: mentioning_user.username)
    comment_field = find(new_comment_field)
    comment_field.set("@#{fragment}")
    expect_at_mention_suggestion_count(1)
    comment_field.send_keys(:tab)
    expect_no_at_mention_suggestions
    expect(comment_field.value).to eq "@#{mentioning_user.username} "
    submit_comment
  end

  def expect_reply_created(user, count)
    user_name_in_comments(user, count)
    expect(page).to have_content('new reply')
  end

  def expect_view_only_participants
    expect(page).not_to have_css(add_participant_button)
    expect(page).to have_css('.participant-selector')
  end

  def expect_view_no_discussions
    expect(page).to have_css('.discussions-index-header')
    expect(page).not_to have_css('.discussions-index-topic')
  end

  private

  def new_comment_field
    '.discussions-show-form .new-comment-field'
  end

  def discussion_replies
    '.message-comment'
  end

  def at_mention_suggestions
    '.atwho-container li'
  end

  def create_topic_button
    '.discussions-index-header .button-secondary'
  end

  def add_participant_button
    '.add-participant-button'
  end

  def user_name_in_comments(user, count)
    within('.discussions-show-content') { expect(page).to have_content(user.full_name, count: count) }
  end
end
