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
end
