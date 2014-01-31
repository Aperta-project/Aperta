class PaperAdminTask < Task
  title 'Assign Admin'
  role 'admin'

  after_save :assign_tasks_to_admin, if: -> { assignee_id_changed? }

  private

  def assign_tasks_to_admin
    query = Task.where(role: 'admin', completed: false, phase_id: [task_manager.phases.pluck(:id)])
    query = if assignee_id_was.present?
              query.where('assignee_id IS NULL OR assignee_id = ?', assignee_id_was)
            else
              query.where(assignee_id: nil)
            end
    query.update_all(assignee_id: assignee_id)
  end
end
