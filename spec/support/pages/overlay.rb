class CardOverlay < PageFragment
  def dismiss
    all('.close-overlay').first.click
  end

  def assignee
    selected_option = all('#task_assignee_id option[selected]').first
    selected_option.try :text
  end

  def assignee=(name)
    select name, from: 'Assignee'
  end

  def mark_as_complete
    find('footer input[type="checkbox"]').click
  end

  def completed?
    find('footer input[type="checkbox"]').checked?
  end

  def view_paper
    old_position = session.evaluate_script "$('header a').css('position')"
    session.execute_script "$('header a').css('position', 'relative')"
    find('header h2 a').click
    session.execute_script "$('header a').css('position', '#{old_position}')"
    PaperPage.new
  end
end
