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

require 'support/pages/fragments/phase_fragment'
require 'support/pages/page_fragment'
require 'support/pages/paper_page'
require 'support/pages/task_manager_page'

class TaskManagerPage < Page

  path :root
  text_assertions :task, '.card'

  def phases
    expect(page).to have_css('.column h2')
    retry_stale_element do
      session.all(:css, ".column h2").map(&:text)
    end
  end

  def phase(phase_name)
    PhaseFragment.new(
      find('.column h2', text: phase_name).find(:xpath, '../../..'))
  end

  def phase_count
    TaskManagerPage.new.phases.count
  end

  def card_count
    all(".card").size
  end

  def tasks
    session.has_content? 'Add new card'
    all('.card').map { |el| TaskCard.new(el) }
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    PaperPage.new
  end

  def paper_title
    find("#control-bar-paper-title")
  end
end

class TaskCard < PageFragment
  def unread_comments_badge
    find('.badge.unread-comments-count').text.to_i
  end
end
