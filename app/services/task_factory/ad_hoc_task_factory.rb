module TaskFactory
  class AdHocTaskFactory
    def self.build(task_params, user)
      task = Task.new(task_params)
      task.role = 'admin'
      task.save
      task
    end
  end
end
