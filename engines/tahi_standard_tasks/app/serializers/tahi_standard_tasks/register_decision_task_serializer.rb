module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id
    has_many :letter_templates,
             embed: :ids,
             include: true

    def letter_templates
      object.letter_templates.map do |t|
        t.render(manuscript: object.paper)
      end
    end
  end
end
