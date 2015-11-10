module TahiStandardTasks
  class InitialDecisionTask < Task

    register_task default_title: 'Initial Decision', default_role: 'editor'

    def initial_decision
      paper.decisions.last
    end

    def active_model_serializer
      InitialDecisionTaskSerializer
    end

    def paper_creation_hook(paper)
      paper.update_column(:gradual_engagement, true)
    end
  end
end
