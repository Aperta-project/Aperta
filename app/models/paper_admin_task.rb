class PaperAdminTask < Task
  title 'Assign Admin'
  role 'admin'

  attr_accessor :admin_id

  after_save :update_paper_admin_and_tasks, if: :paper_admin_changed?

  def tasks_for_admin
    Task.where(role: 'admin', completed: false, phase_id: [task_manager.phases.pluck(:id)], assignee_id: assignee_id)
  end

  def update_responder
    UpdateResponders::PaperAdminTask
  end

  def permitted_attributes
    super + [:admin_id]
  end

  private

  def update_paper_admin_and_tasks
    #TODO: eventually move callback to controller
    TaskAdminAssigneeUpdater.new(self).update
  end

  def paper_admin_changed?
    paper.admin != User.where(id: admin_id).first
  end
end
