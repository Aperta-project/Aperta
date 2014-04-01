module StandardTasks
  class RegisterDecisionTaskPresenter < TaskPresenter
    def data_attributes
      super.merge({
        'decisionLetters' => {"Accepted" => task.accept_letter,
                              "Rejected" => task.reject_letter,
                              "Revise"   => task.revise_letter},
                              'decision' => task.paper.decision,
                              'decisionLetter' => task.paper.decision_letter
      })
    end
  end
end
