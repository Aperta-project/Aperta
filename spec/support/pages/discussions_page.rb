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

  def expect_view_topic
    expect(find('h1.discussions-show-title'))
    expect(find('.participant-selector'))
    expect(find('.discussions-show-form'))
  end

  def add_reply
    find('.discussions-show-form .new-comment-field').set('new reply')
    find('.discussions-show-form .new-comment-field').send_keys(:tab)
    wait_for_ajax
    find('button.new-comment-submit-button').click
    wait_for_ajax
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
