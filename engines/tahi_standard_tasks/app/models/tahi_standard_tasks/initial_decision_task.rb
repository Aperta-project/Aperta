module TahiStandardTasks
  class InitialDecisionTask < Task

    DEFAULT_TITLE = 'Initial Decision'
    DEFAULT_ROLE = 'editor'

    def initial_decision
      paper.decisions.last
    end

    def active_model_serializer
      InitialDecisionTaskSerializer
    end

    def paper_creation_hook(paper)
      paper.update_column(:gradual_engagement, true)
    end

    def before_register(decision)
      decision.initial = true
    end

    def after_register(decision)
      complete!
    end

    def send_email
      InitialDecisionMailer.delay.notify decision_id: initial_decision.id
    end
  end
end
