module StandardTasks
  class TaskAdminAssigneeUpdater
    attr_accessor :task, :paper, :task_admin, :previous_task_admin

    def initialize(task)
      @task = task
      @paper = task.paper
      @task_admin = User.where(id: task.admin_id).first
      @previous_task_admin = paper.admins.first
    end

    def update
      paper.transaction do
        paper.assign_admin!(task_admin)
        related_tasks.each do |task|
          task.assignee = task_admin
          task.save
          AssignmentManager.new(task, nil).sync
        end
      end
    end

    private

    def related_tasks
      paper.tasks.without(task).for_admins.incomplete.assigned_to(nil, previous_task_admin)
    end
  end
end
