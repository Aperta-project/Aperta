module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id, :decision_letters, :paper_decision_letter

    def decision_letters
      { accept: object.accept_letter,
        reject: object.reject_letter,
        major_revision: object.major_revision_letter,
        minor_revision: object.minor_revision_letter }.to_json
    end
  end
end
