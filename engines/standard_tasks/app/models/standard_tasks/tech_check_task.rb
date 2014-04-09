module StandardTasks
  class TechCheckTask < Task
    title 'Tech Check'
    role 'admin'

    def active_model_serializer
      TaskSerializer
    end
  end
end
