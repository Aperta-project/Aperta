module TahiStandardTasks
  class InitialDecisionTask < Task

    register_task default_title: 'Initial Decision', default_role: 'editor'

    def initial_decision
      paper.decisions.first
    end

    def active_model_serializer
      InitialDecisionTaskSerializer
    end

  end
end
