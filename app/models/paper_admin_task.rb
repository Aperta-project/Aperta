class PaperAdminTask < Task
  title 'Assign Admin'
  role 'admin'

  attr_accessor :admin_id

  PERMITTED_ATTRIBUTES = [:admin_id]

  after_save :update_paper_admin_and_tasks, if: :paper_admin_changed?

  def tasks_for_admin
    Task.where(role: 'admin', completed: false, phase_id: [task_manager.phases.pluck(:id)], assignee_id: assignee_id)
  end

  def update_responder
    UpdateResponders::PaperAdminTask
  end

  private

  def update_paper_admin_and_tasks
    binding.pry
    TaskAdminAssigneeUpdater.new(self).update

    # query = Task.where(role: 'admin', completed: false, phase_id: [task_manager.phases.pluck(:id)])
    # query = if assignee_id_was.present?
    #           query.where('assignee_id IS NULL OR assignee_id = ?', assignee_id_was)
    #         else
    #           query.where(assignee_id: nil)
    #         end
    # query.update_all(assignee_id: assignee_id)
  end

  def paper_admin_changed?
    paper.admin != User.where(id: admin_id).first
  end
end
