module TaskCreator
  def self.call(task_params, creator)
    task = Task.new(task_params)
    task.role = 'admin'
    task.save
    task
  end
end
