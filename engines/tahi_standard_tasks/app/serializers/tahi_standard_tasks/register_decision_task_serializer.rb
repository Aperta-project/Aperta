module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id, :paper_decision_letter
    has_many :letter_templates,
             embed: :ids,
             include: true
  end
end
