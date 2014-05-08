module UpdateResponders
  class PaperReviewerTask < UpdateResponders::Task
    private
    def status
      200
    end

    def content
      paper_reviewer_tasks = @task.paper.tasks.where(type: ReviewerReportTask)
      # phases = @task.paper.phases.where(id: paper_reviewer_tasks.pluck(:phase_id).push(@task.phase_id))
      # phases = @task.paper.phases.where(id: [186, 187, 188, 189, 190])
      # phases = @task.paper.phases.where(id: [188, 189])
      phases = @task.paper.phases.where(id: [187, 188, 189])
      # phases = @task.paper.phases

      json = ActiveModel::ArraySerializer.new(phases, root: :phases).as_json
      json
    end
  end
end
