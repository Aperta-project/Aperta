class TaskAdminAssigneeUpdater

  attr_accessor :task, :paper, :task_admin, :previous_assignee, :previous_admin

  def initialize(task)
    @task = task
    @paper = task.paper
    @task_admin = User.where(id: task.admin_id).first
    @previous_admin = paper.admin
    @previous_assignee = task.assignee
  end

  def update
    paper.transaction do
      paper.assign_admin!(task_admin)
      paper.tasks.without(task).incomplete.admin.update_all(assignee_id: task_admin)
      if admin_was_assignee?
        task.update_column(:assignee_id, task_admin)
      end
    end
  end


  private

  def admin_was_assignee?
    previous_admin.blank? || (previous_admin == previous_assignee)
  end

end
