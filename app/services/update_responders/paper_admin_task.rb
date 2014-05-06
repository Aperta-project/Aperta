module UpdateResponders
  class PaperAdminTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      json = ActiveModel::ArraySerializer.new(@task.tasks_for_admin, root: :tasks).as_json
      json[:tasks].unshift @task.active_model_serializer.new(@task).as_json[:task]
      json[:tasks] = json[:tasks].uniq { |task| task[:id] }
      json
    end
  end
end
