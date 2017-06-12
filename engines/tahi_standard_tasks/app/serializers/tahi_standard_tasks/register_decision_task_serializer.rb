module TahiStandardTasks
  class RegisterDecisionTaskSerializer < ::TaskSerializer
    attributes :id
    has_many :letter_templates,
             embed: :ids,
             include: true

    def letter_templates
      context = RegisterDecisionScenario.new(object.paper)
      object.letter_templates.map do |t|
        t.render(context)
      end
    end
  end
end
