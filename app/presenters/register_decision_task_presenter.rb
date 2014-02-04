class RegisterDecisionTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'decision-letters' => {"Accepted" => task.accept_letter,
                             "Rejected" => task.reject_letter,
                             "Revise"   => task.revise_letter}.to_json,
      'decision' => task.paper.decision,
      'decision-letter' => task.paper.decision_letter
    })
  end
end
