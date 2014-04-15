class RegisterDecisionOverlay < CardOverlay
  def register_decision=(decision)
    choose decision
  end

  def decision_letter=(body)
    wait_for_pjax
    fill_in 'task_paper_decision_letter', with: body
    find('label[for=assignee]').click
  end

  def decision_letter
    find('#task_paper_decision_letter').value
  end

  def accepted?
    find('#accepted_option:checked')
  end
end
