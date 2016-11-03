module TahiStandardTasks
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
    DEFAULT_TITLE = 'Assign Admin'
    DEFAULT_ROLE = 'admin'

    attr_accessor :admin_id

    after_save :update_paper_admin_and_tasks, if: :paper_admin_changed?

    def self.permitted_attributes
      super + [:admin_id]
    end

    def tasks_for_admin
      paper.tasks.without(self).for_old_role('admin').incomplete
    end

    def update_responder
      PaperAdminResponder # TODO: Kill me please
    end

    private

    def update_paper_admin_and_tasks
      # TODO: eventually move callback to controller
      paper.transaction do
        admin = User.find(admin_id)
        paper.assignments
             .where(role: paper.journal.staff_admin_role)
             .destroy_all
        paper.assignments
             .create!(user: admin, role: paper.journal.staff_admin_role)
      end
    end

    def paper_admin_changed?
      if admin_id
        # if the admin for this task doesn't in the paper's admins (in reality there's only going
        # to be 1) then this admin must be a new one.
        !paper.journal.staff_admins.exists?(id: admin_id)
      else
        # maybe we're trying to get rid of the current admin.
        # if an admin PaperRole exists and we're setting admin_id to nil, return true.
        paper.journal.staff_admins.exists?
      end
    end
  end
end
