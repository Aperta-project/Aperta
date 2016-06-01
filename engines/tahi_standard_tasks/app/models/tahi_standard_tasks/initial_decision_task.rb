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

    def register(decision)
      paper.make_decision decision
      paper.decisions.create(notify_requester: true) unless decision.terminal?
      decision.initial = true
      InitialDecisionMailer.delay.notify decision_id: decision.id
      decision.registered = true
      decision.initial = true
      decision.save!
      complete!
    end
  end
end
