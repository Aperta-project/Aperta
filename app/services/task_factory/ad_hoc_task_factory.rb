module TaskFactory
  class AdHocTaskFactory
    def self.build(klass, task_params, _user)
      klass.create!(task_params)
    end
  end
end
