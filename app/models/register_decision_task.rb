class RegisterDecisionTask < Task
  PERMITTED_ATTRIBUTES = [:paper_decision, :paper_decision_letter]

  title "Register Decision"
  role "editor"

  def paper_decision
    paper.decision
  end

  def paper_decision=(decision)
    paper.update(decision: decision)
  end

  def paper_decision_letter
    paper.decision_letter
  end

  def paper_decision_letter=(body)
    paper.update(decision_letter: body)
  end
end
