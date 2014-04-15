class TaskAdminAssigneeUpdater

  attr_accessor :task, :paper, :task_admin, :previous_assignee, :previous_admin

  def initialize(task)
    @task           = task
    @paper          = task.paper
    @task_admin     = User.where(id: task.admin_id).first
    @previous_admin = paper.admin
    @previous_assignee = task.assignee
  end

  def update
    paper.transaction do
      paper.assign_admin!(task_admin)
      paper.tasks.incomplete.admin.update_all(assignee_id: task_admin)
      if previous_admin.present? && previous_admin != previous_assignee
        task.update_column(:assignee_id, previous_assignee)
      end
    end
  end

end
