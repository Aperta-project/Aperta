module TahiStandardTasks
  class PreprintDecisionScenario < PaperScenario
    def self.object_class
      Task
    end

    def author
      UserContext.new(task.paper.creator)
    end

    private

    def manuscript_object
      task.paper
    end

    def task
      @object
    end
  end
end
