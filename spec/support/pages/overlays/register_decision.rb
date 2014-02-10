class RegisterDecisionOverlay < CardOverlay
  def register_decision=(decision)
    choose decision
  end

  def decision_letter=(body)
    fill_in 'task_paper_decision_letter', with: body
    find('label[for=task_assignee_id]').click
    wait_for_pjax
  end

  def decision_letter
    find('#task_paper_decision_letter').value
  end

  def accepted?
    find('input[type="radio"][checked]')[:value] == 'Accepted'
  end
end
