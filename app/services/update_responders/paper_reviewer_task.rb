module UpdateResponders
  class PaperReviewerTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      json = ActiveModel::ArraySerializer.new(@task.paper.phases, root: :phases).as_json
      json[:tasks].unshift @task.active_model_serializer.new(@task).as_json[:task]
      json[:tasks] = json[:tasks].uniq { |task| task[:id] }
      json
    end
  end
end
