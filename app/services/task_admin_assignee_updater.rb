class TaskAdminAssigneeUpdater

  attr_accessor :task, :paper, :task_admin

  def initialize(task)
    @task = task
    @paper = task.paper
    @task_admin = User.where(id: task.admin_id).first
  end

  def update
    paper.transaction do
      paper.assign_admin!(task_admin)
      paper.tasks.without(task).incomplete.only_admin.update_all(assignee_id: task_admin)
    end
  end

end
