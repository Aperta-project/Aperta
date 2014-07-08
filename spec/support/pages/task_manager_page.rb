class TaskManagerPage < Page

  path :manage_paper

  def phases
    expect(session).to have_css('.column h2')
    retry_stale_element do
      session.all(:css, ".column h2").map(&:text)
    end
  end

  def phase phase_name
    expect(page).to have_content(phase_name) # use have_content/css/stuff assertion to avoid sleeps.
    PhaseFragment.new(all('.column').detect {|p| p.find('h2').text == phase_name })
  end

  def phase_count
    TaskManagerPage.new.phases.count
  end

  def tasks
    retry_stale_element do
      all('.card').map(&:text)
    end
  end

  def has_task?(task_name)
    expect(session).to have_css('.card', text: task_name)
  end

  def has_no_task?(task_name)
    expect(session).to have_no_css('.card', text: task_name)
  end

  def message_tasks
    synchronize_content! "Add new card"
    all('.card-message').map { |el| MessageTaskCard.new(el) }
  end

  def get_first_matching_task name
    all('.card-content').detect { |card| card.text == name }
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    EditPaperPage.new
  end
end

class MessageTaskCard < PageFragment
  def unread_comments_badge
    find('.badge.unread-comments-count').text.to_i
  end
end
