module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id, :decision_letters, :paper_decision_letter

    def decision_letters
      { accept: object.accept_templates,
        reject: object.reject_templates,
        major_revision: object.major_revision_templates,
        minor_revision: object.minor_revision_templates }.to_json
    end
  end
end
