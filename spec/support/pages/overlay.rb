class CardOverlay < Page
  path :paper_task

  def dismiss
    all('a').detect { |a| a.text == 'CLOSE' }.click
  end

  def assignee
    all('.chosen-assignee.chosen-container').first.text
  end

  def assignee=(name)
    select_from_chosen name, class: 'chosen-assignee'
  end

  def title
    find('main > h1').text
  end

  def body
    find('main > p').text
  end

  def mark_as_complete
    check "Completed"
    check "Completed" unless completed?
  end

  def completed?
    find(checkbox_selector).checked?
  end

  def view_paper
    old_position = session.evaluate_script "$('header a').css('position')"
    session.execute_script "$('header a').css('position', 'relative')"
    find('header h2 a').click
    session.execute_script "$('header a').css('position', '#{old_position}')"
    wait_for_turbolinks
    PaperPage.new
  end

  private
  def checkbox_selector
    'footer input[type=checkbox]'
  end
end
