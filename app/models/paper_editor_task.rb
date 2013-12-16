class PaperEditorTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_role_attributes: [:user_id] }]

  after_initialize :initialize_defaults

  def paper_role
    PaperRole.where(paper: phase.task_manager.paper, editor: true).first_or_initialize
  end

  def paper_role_attributes=(attributes)
    paper_role.update attributes
  end

  private

  def initialize_defaults
    self.title = 'Assign Editor' if title.blank?
    self.role = 'admin' if role.blank?
  end
end
