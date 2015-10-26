module TahiStandardTasks
  class InitialDecisionTask < Task

    register_task default_title: 'Initial Decision', default_role: 'editor'

    def active_model_serializer
      InitialDecisionTaskSerializer
    end

  end
end
