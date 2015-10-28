module TahiStandardTasks
  class InitialDecisionTask < Task

    register_task default_title: 'Initial Decision', default_role: 'editor'

    def initial_decision
      paper.decisions.first
    end

    def send_email
      # InitialDecisionMailer.delay.notify_author
    end

    def active_model_serializer
      InitialDecisionTaskSerializer
    end

  end
end
