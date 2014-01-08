class RegisterDecisionOverlay < CardOverlay
  def register_decision=(decision)
    choose decision
  end

  def decision_letter=(body)
    fill_in 'Decision Letter', with: body
  end

  def decision_letter
    find('textarea#task_paper_decision_letter').value
  end

  def accepted?
    find('input[type="radio"][checked=checked]')[:value] == 'Accepted'
  end
end
