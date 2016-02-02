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
