class AssignReviewerOverlay < CardOverlay
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    session.execute_script(%Q!$("##{field[:id]}_chosen").mousedown()!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").val("#{item_text}")!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").keyup()!)
    session.execute_script(%Q!$("##{field[:id]}_chosen input").trigger(jQuery.Event("keyup", { keyCode: 13 }))!)
  end

  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, from: 'Reviewers' }
  end

  def paper_reviewers
    all('#task_paper_roles option[selected]', visible: false).map(&:text)
  end
end
