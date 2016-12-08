module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id
    has_many :letter_templates,
             embed: :ids,
             include: true
  end
end
