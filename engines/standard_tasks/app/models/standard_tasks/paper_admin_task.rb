module StandardTasks
  class PaperAdminResponder < ::UpdateResponders::Task

    private

    def status
      200
    end

    def content
      generate_json_response(@task.tasks_for_admin, :tasks)
    end
  end

  class PaperAdminTask < Task
    title 'Assign Admin'
    role 'admin'

    attr_accessor :admin_id

    after_save :update_paper_admin_and_tasks, if: :paper_admin_changed?

    def tasks_for_admin
      Task.where(role: 'admin', completed: false, phase_id: [paper.phase_ids], assignee_id: assignee_id)
    end

    def update_responder
      PaperAdminResponder # TODO: Kill me please
    end

    def permitted_attributes
      super + [:admin_id]
    end

    private

    def update_paper_admin_and_tasks
      # TODO: eventually move callback to controller
      TaskAdminAssigneeUpdater.new(self).update
    end

    def paper_admin_changed?
      !paper.admins.exists?(id: admin_id)
    end
  end
end
