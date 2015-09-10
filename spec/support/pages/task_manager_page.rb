class TaskManagerPage < Page

  path :root
  text_assertions :task, '.card'

  def phases
    expect(page).to have_css('.column h2')
    retry_stale_element do
      session.all(:css, ".column h2").map(&:text)
    end
  end

  def phase phase_name
    expect(page).to have_css(".column-title", text: phase_name) # use have_content/css/stuff assertion to avoid sleeps.
    retry_stale_element do
      PhaseFragment.new(all('.column').detect { |p| p.has_css?('h2', text: phase_name) })
    end
  end

  def phase_count
    TaskManagerPage.new.phases.count
  end

  def card_count
    all(".card").size
  end

  def tasks
    synchronize_content! "Add card"
    all('.card').map { |el| TaskCard.new(el) }
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    PaperPage.new
  end

  def journal_name
    find("#control-bar-paper-journal-name")
  end

  def paper_title
    find("h2.tasks-paper-title")
  end
end

class TaskCard < PageFragment
  def unread_comments_badge
    find('.badge.unread-comments-count').text.to_i
  end
end
