module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id, :decision_letters, :paper_decision, :paper_decision_letter

    def decision_letters
      { Accepted: object.accept_letter,
        Rejected: object.reject_letter,
        Revise: object.revise_letter }.to_json
    end
  end
end
