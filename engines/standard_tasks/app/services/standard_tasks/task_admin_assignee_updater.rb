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
          if !task.participants.include?(task_admin)
            task.participants << task_admin
            UserMailer.delay.add_participant(nil, task_admin.id, task.id)
            CommentLookManager.sync_task(task)
          end
        end
      end
    end

    private

    def related_tasks
      paper.tasks.without(task).for_admins.incomplete.assigned_to(nil, previous_task_admin)
    end
  end
end
