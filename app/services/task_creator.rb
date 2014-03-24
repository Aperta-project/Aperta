module TaskCreator
  def self.call(task_params, creator)
    # task.role = 'admin'
    task = Task.new(task_params)
    task.role = 'admin'
    task.save
    task
  end
end
