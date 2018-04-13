# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'support/pages/page'
require 'support/pages/paper_page'

class CardOverlay < Page
  path :root

  def dismiss
    session.all('.overlay .overlay-close-button').first.click
    expect(page).to have_no_css('.overlay')
  end

  text_assertions :assignee, '.chosen-assignee.chosen-container', ->(name) { name.upcase }

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
    expect(self).to be_completed
  end

  def mark_as_incomplete
    find('.task-completed').click
  end

  def completed?
    has_css?('.task-is-completed')
  end

  def uncompleted?
    has_css?('.task-not-completed')
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
