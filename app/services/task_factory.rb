module TaskFactory
  def self.build_task(task_type, task_params, user)
    task_factories[task_type.to_sym].build task_params, user
  end

  def self.task_factories
    {
      Task: AdHocTaskFactory,
      MessageTask: MessageTaskFactory
    }
  end
end
