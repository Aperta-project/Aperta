module StandardTasks
  class TechCheckTask < Task
    register_task default_title: 'Tech Check', default_role: 'admin'

    def active_model_serializer
      TaskSerializer
    end
  end
end
