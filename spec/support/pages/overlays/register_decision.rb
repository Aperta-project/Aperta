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
    find('#accepted_option:checked')
  end
end
