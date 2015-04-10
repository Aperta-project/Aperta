module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id, :decision_letters, :paper_decision_letter

    has_many :decisions, embed: :ids, include: true, serializer: DecisionSerializer

    def decisions
      paper.decisions
    end

    def decision_letters
      { Accepted: object.accept_letter,
        Rejected: object.reject_letter,
        Revise: object.revise_letter }.to_json
    end
  end
end
