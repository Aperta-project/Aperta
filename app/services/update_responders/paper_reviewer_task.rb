module UpdateResponders
  class PaperReviewerTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      tasks = @task.paper.tasks_for_type("ReviewerReportTask").assigned_to(current_user)
      ActiveModel::ArraySerializer.new(tasks, root: :tasks)
    end
  end
end
