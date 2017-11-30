module TahiStandardTasks
  class PreprintDecisionScenario < PaperScenario
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
