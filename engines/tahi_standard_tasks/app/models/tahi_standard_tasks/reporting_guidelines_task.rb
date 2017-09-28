module TahiStandardTasks
  class ReportingGuidelinesTask < ::Task
    def active_model_serializer
      TaskSerializer
    end
  end
end
