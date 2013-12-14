class PaperAdminTask < Task
  after_initialize :initialize_defaults
  after_save :assign_tasks_to_admin

  private

  def initialize_defaults
    self.title = 'Paper Shepherd' if title.blank?
  end

  def assign_tasks_to_admin
    Task.where(role: 'admin').where(["assignee_id = ? OR assignee_id IS NULL", assignee_id_was]).update_all(assignee_id: assignee.id)
  end
end
