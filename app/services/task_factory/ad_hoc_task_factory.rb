module TaskFactory
  class AdHocTaskFactory
    def self.build(task_params, user)
      Task.create!(task_params)
    end
  end
end
