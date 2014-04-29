module UpdateResponders
  class PaperReviewerTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      phases = @task.paper.phases.where(name: 'Get Reviews')
      json = ActiveModel::ArraySerializer.new(phases, root: :phases).as_json
      json[:tasks].unshift @task.active_model_serializer.new(@task).as_json[:task]
      json
    end
  end
end
