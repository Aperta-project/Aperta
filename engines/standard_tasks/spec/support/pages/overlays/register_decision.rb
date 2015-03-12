class RegisterDecisionOverlay < CardOverlay
  def register_decision=(decision)
    choose decision
  end

  def decision_letter=(body)
    synchronize_content!("Accepted")
    find('.decision-letter-field').set(body)
  end

  def decision_letter
    find('.decision-letter-field').get()
  end

  def accepted?
    find('input[value="accepted"]')
  end

  def disabled?
    find("#task_completed[disabled]") != nil &&
    all("input[type='radio'][disabled]").size == 3 &&
    find("textarea[disabled]") != nil
  end
end
