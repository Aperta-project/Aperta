module TahiStandardTasks
  # Shell class to be deleted later. This has been replaced with a custom card
  class DataAvailabilityTask < ::Task
    def active_model_serializer
      TaskSerializer
    end
  end
end
